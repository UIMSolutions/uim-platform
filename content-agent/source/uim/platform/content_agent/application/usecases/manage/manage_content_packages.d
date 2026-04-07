/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.application.usecases.manage.content_packages;

import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.entities.content_activity;
import uim.platform.content_agent.domain.ports.repositories.content_packages;
import uim.platform.content_agent.domain.ports.repositories.content_providers;
import uim.platform.content_agent.domain.ports.repositories.content_activitys;
import uim.platform.content_agent.domain.services.package_assembler;
import uim.platform.content_agent.domain.types;

// import std.conv : to;

/// Application service for content package CRUD and assembly.
class ManageContentPackagesUseCase : UIMUseCase {
  private ContentPackageRepository packageRepo;
  private ContentProviderRepository providerRepo;
  private ContentActivityRepository activityRepo;

  this(ContentPackageRepository packageRepo,
      ContentProviderRepository providerRepo, ContentActivityRepository activityRepo) {
    this.packageRepo = packageRepo;
    this.providerRepo = providerRepo;
    this.activityRepo = activityRepo;
  }

  CommandResult createPackage(CreatePackageRequest req) {
    auto existing = packageRepo.findByName(req.tenantId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Package with name '" ~ req.name ~ "' already exists");

    if (req.name.length == 0)
      return CommandResult(false, "", "Package name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    ContentPackage pkg;
    pkg.id = id;
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

    packageRepo.save(pkg);
    recordActivity(req.tenantId, ActivityType.packageCreated, id, req.name,
        "Package created", req.createdBy);

    return CommandResult(true, id, "");
  }

  CommandResult updatePackage(ContentPackageId id, UpdatePackageRequest req) {
    auto pkg = packageRepo.findById(id);
    if (pkg.id.length == 0)
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

    packageRepo.update(pkg);
    return CommandResult(true, id, "");
  }

  CommandResult assemblePackage(AssemblePackageRequest req) {
    auto pkg = packageRepo.findById(req.packageId);
    if (pkg.id.length == 0)
      return CommandResult(false, "", "Package not found");

    if (pkg.status != PackageStatus.draft)
      return CommandResult(false, "", "Package must be in draft state to assemble");

    auto providers = providerRepo.findByTenant(req.tenantId);
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

    packageRepo.update(pkg);
    recordActivity(req.tenantId, ActivityType.packageAssembled, req.packageId,
        pkg.name, "Package assembled", req.assembledBy);

    return CommandResult(true, req.packageId, "");
  }

  ContentPackage getPackage(ContentPackageId id) {
    return packageRepo.findById(id);
  }

  ContentPackage[] listPackages(TenantId tenantId) {
    return packageRepo.findByTenant(tenantId);
  }

  ContentPackage[] listByStatus(TenantId tenantId, string statusStr) {
    auto status = parsePackageStatus(statusStr);
    return packageRepo.findByStatus(tenantId, status);
  }

  CommandResult deletePackage(ContentPackageId id) {
    auto pkg = packageRepo.findById(id);
    if (pkg.id.length == 0)
      return CommandResult(false, "", "Package not found");

    packageRepo.remove(id);
    recordActivity(pkg.tenantId, ActivityType.packageDeleted, id, pkg.name, "Package deleted", "");

    return CommandResult(true, id, "");
  }

  private void recordActivity(TenantId tenantId, ActivityType actType,
      string entityId, string entityName, string desc, string by) {
    // import std.uuid : randomUUID;
    ContentActivity activity;
    activity.id = randomUUID().toString();
    activity.tenantId = tenantId;
    activity.activityType = actType;
    activity.severity = ActivitySeverity.info;
    activity.entityId = entityId;
    activity.entityName = entityName;
    activity.description = desc;
    activity.performedBy = by;
    activity.timestamp = clockSeconds();
    activityRepo.save(activity);
  }

  private static long clockSeconds() {
    // import std.datetime.systime : Clock;
    return Clock.currTime().toUnixTime();
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
