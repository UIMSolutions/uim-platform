/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.manage.content_packages;

// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.entities.content_provider;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.ports.repositories.content_packages;
// import uim.platform.content_agent.domain.ports.repositories.content_providers;
// import uim.platform.content_agent.domain.ports.repositories.content_activitys;
// import uim.platform.content_agent.domain.services.package_assembler;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
// import std.conv : to;

/// Application service for content package CRUD and assembly.
class ManageContentPackagesUseCase { // TODO: UIMUseCase {
  private ContentPackageRepository packages;
  private ContentProviderRepository providers;
  private ContentActivityRepository activities;

  this(ContentPackageRepository packages,
      ContentProviderRepository providers, ContentActivityRepository activities) {
    this.packages = packages;
    this.providers = providers;
    this.activities = activities;
  }

  CommandResult createPackage(CreatePackageRequest req) {
    auto existing = packages.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Package with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Package name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID();

    ContentPackage pkg;
    pkg.id = randomUUID();
    pkg.tenantId = req.tenantId;
    pkg.subaccountId = req.subaccountId;
    pkg.name = req.name;
    pkg.description = req.description;
    pkg.version_ = req.version_;
    pkg.format = parseContentFormat(req.format);
    pkg.items = req.items;
    pkg.tags = req.tags;
    pkg.status = PackageStatus.draft;
    pkg.createdBy = req.createdBy;

    import core.time : MonoTime;

    pkg.createdAt = clockSeconds();
    pkg.updatedAt = pkg.createdAt;

    packages.save(pkg);
    recordActivity(req.tenantId, ActivityType.packageCreated, id, req.name,
        "Package created", req.createdBy);

    return CommandResult(true, id.value, "");
  }

  CommandResult updatePackage(ContentPackageId id, UpdatePackageRequest req) {
    auto pkg = packages.findById(id);
    if (pkg.isNull)
      return CommandResult(false, "", "Package not found");

    if (req.description.length > 0)
      pkg.description = req.description;
    if (req.version_.length > 0)
      pkg.version_ = req.version_;
    if (req.items.length > 0)
      pkg.items = req.items;
    if (req.tags.length > 0)
      pkg.tags = req.tags;
    pkg.updatedAt = clockSeconds();

    // Reset to draft if items changed
    if (req.items.length > 0)
      pkg.status = PackageStatus.draft;

    packages.update(pkg);
    return CommandResult(true, id.value, "");
  }

  CommandResult assemblePackage(AssemblePackageRequest req) {
    auto pkg = packages.findById(req.packageId);
    if (pkg.isNull)
      return CommandResult(false, "", "Package not found");

    if (pkg.status != PackageStatus.draft)
      return CommandResult(false, "", "Package must be in draft state to assemble");

    auto providers = providers.findByTenant(req.tenantId);
    auto result = PackageAssembler.validate(pkg, providers);
    if (!result.valid) {
      string msg = "Assembly validation failed: ";
      foreach (i, e; result.errors) {
        if (i > 0)
          msg ~= "; ";
        msg ~= e;
      }
      return CommandResult(false, "", msg);
    }

    pkg.status = PackageStatus.assembled;
    pkg.assembledAt = clockSeconds();
    pkg.updatedAt = pkg.assembledAt;
    pkg.packageSizeBytes = result.estimatedSizeBytes;

    packages.update(pkg);
    recordActivity(req.tenantId, ActivityType.packageAssembled, req.packageId,
        pkg.name, "Package assembled", req.assembledBy);

    return CommandResult(true, req.packageId, "");
  }

  ContentPackage getPackage(ContentPackageId id) {
    return packages.findById(id);
  }

  ContentPackage[] listPackages(TenantId tenantId) {
    return packages.findByTenant(tenantId);
  }

  ContentPackage[] listByStatus(TenantId tenantId, string statusStr) {
    auto status = parsePackageStatus(statusStr);
    return packages.findByStatus(tenantId, status);
  }

  CommandResult deletePackage(ContentPackageId id) {
    auto pkg = packages.findById(id);
    if (pkg.isNull)
      return CommandResult(false, "", "Package not found");

    packages.removeById(id);
    recordActivity(pkg.tenantId, ActivityType.packageDeleted, id, pkg.name, "Package deleted", "");

    return CommandResult(true, id.value, "");
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by) {
    // import std.uuid : randomUUID;
    ContentActivity activity;
    activity.id = randomUUID();
    activity.tenantId = tenantId;
    activity.activityType = actType;
    activity.severity = ActivitySeverity.info;
    activity.entityId = entityId;
    activity.entityName = entityName;
    activity.description = desc;
    activity.performedBy = by;
    activity.timestamp = clockSeconds();
    activities.save(activity);
  }

  private static ContentFormat parseContentFormat(string s) {
    switch (s) {
    case "zip":
      return ContentFormat.zip;
    case "json":
      return ContentFormat.json;
    default:
      return ContentFormat.mtar;
    }
  }

  private static PackageStatus parsePackageStatus(string s) {
    switch (s) {
    case "draft":
      return PackageStatus.draft;
    case "assembled":
      return PackageStatus.assembled;
    case "exported":
      return PackageStatus.exported;
    case "inTransport":
      return PackageStatus.inTransport;
    case "delivered":
      return PackageStatus.delivered;
    case "error":
      return PackageStatus.error;
    default:
      return PackageStatus.draft;
    }
  }
}
