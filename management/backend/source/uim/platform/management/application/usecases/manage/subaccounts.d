/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.subaccounts;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage subaccount lifecycle within global accounts.
class ManageSubaccountsUseCase : IManageSubaccountsUseCase {
  protected ISubaccountRepository repository;
  protected IGlobalAccountRepository globalAccounts;
  protected IDirectoryRepository directories;
  protected IEnvironmentRepository environments;
  protected ISubscriptionRepository subscriptions;
  protected PlatformEventRecorder recorder;

  this(ISubaccountRepository repository, IGlobalAccountRepository globalAccounts,
      IDirectoryRepository directories, IEnvironmentRepository environments,
      ISubscriptionRepository subscriptions, PlatformEventRecorder recorder) {
    this.repository = repository;
    this.globalAccounts = globalAccounts;
    this.directories = directories;
    this.environments = environments;
    this.subscriptions = subscriptions;
    this.recorder = recorder;
  }

  UsecaseResult createSubaccount(CreateSubaccountRequest req) {
    if (req.globalAccountId.isEmpty)
      return invalid("Global account ID is required");
    if (req.displayName.length == 0)
      return invalid("Display name is required");
    if (req.subdomain.length == 0)
      return invalid("Subdomain is required");
    if (!isValidSubdomain(req.subdomain))
      return invalid("Subdomain '" ~ req.subdomain ~ "' must consist of lower case letters, digits and hyphens");
    if (req.region.length == 0)
      return invalid("Region is required");
    SubaccountUsage usage = SubaccountUsage.unset;
    if (req.usage.length > 0 && !tryParseEnum!SubaccountUsage(req.usage, usage))
      return invalid("Unknown usage '" ~ req.usage ~ "' (expected " ~ enumNames!SubaccountUsage().join(", ") ~ ")");

    auto ga = globalAccounts.findById(req.tenantId, req.globalAccountId);
    if (ga.isNull)
      return notFound("Global account");
    if (!ga.isActive)
      return violation("Global account '" ~ ga.displayName ~ "' is " ~ enumName(ga.status));
    if (!req.parentDirectoryId.isEmpty) {
      auto dir = directories.findById(req.tenantId, req.parentDirectoryId);
      if (dir.isNull)
        return notFound("Directory");
      if (dir.globalAccountId != req.globalAccountId)
        return violation("Directory belongs to another global account");
    }
    if (repository.existsBySubdomain(req.tenantId, req.subdomain))
      return conflict("Subdomain '" ~ req.subdomain ~ "' is already taken");

    return guarded(() {
      ga.ensureSubaccountCapacity(repository.findByGlobalAccount(req.tenantId, ga.id).length);

      auto subaccount = Subaccount(req.tenantId);
      subaccount.globalAccountId = req.globalAccountId;
      subaccount.parentDirectoryId = req.parentDirectoryId;
      subaccount.displayName = req.displayName;
      subaccount.description = req.description;
      subaccount.subdomain = req.subdomain;
      subaccount.region = req.region;
      subaccount.usage = usage;
      subaccount.betaEnabled = req.betaEnabled;
      subaccount.usedForProduction = req.usedForProduction || usage == SubaccountUsage.production;
      subaccount.technicalName = subaccount.id.value;
      subaccount.status = SubaccountStatus.active;
      subaccount.labels = req.labels;
      subaccount.customProperties = req.customProperties;
      subaccount.createdBy = actor(req.createdBy);
      subaccount.updatedBy = subaccount.createdBy;

      repository.save(subaccount);
      recorder.record(req.tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
        EnvironmentEventCategory.subaccountLifecycle, "subaccount.created",
        "Subaccount created: " ~ subaccount.displayName, subaccount.createdBy);
      return created(subaccount.id.value, "Subaccount created");
    });
  }

  UsecaseResult updateSubaccount(UpdateSubaccountRequest req) {
    auto subaccount = repository.findById(req.tenantId, req.subaccountId);
    if (subaccount.isNull)
      return notFound("Subaccount");

    if (req.displayName.length > 0)
      subaccount.displayName = req.displayName;
    if (req.description.length > 0)
      subaccount.description = req.description;
    if (req.usage.length > 0) {
      SubaccountUsage usage;
      if (!tryParseEnum!SubaccountUsage(req.usage, usage))
        return invalid("Unknown usage '" ~ req.usage ~ "'");
      subaccount.usage = usage;
    }
    subaccount.betaEnabled = req.betaEnabled;
    subaccount.usedForProduction = req.usedForProduction;
    if (req.labels.length > 0)
      subaccount.labels = req.labels;
    if (req.customProperties.length > 0)
      subaccount.customProperties = req.customProperties;
    subaccount.update();

    repository.update(subaccount);
    recorder.record(req.tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
      EnvironmentEventCategory.subaccountLifecycle, "subaccount.updated",
      "Subaccount updated: " ~ subaccount.displayName, subaccount.updatedBy);
    return ok(subaccount.id.value, "Subaccount updated");
  }

  UsecaseResult moveSubaccount(TenantId tenantId, SubaccountId id, MoveSubaccountRequest req) {
    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.isNull)
      return notFound("Subaccount");
    if (!req.targetDirectoryId.isEmpty) {
      auto dir = directories.findById(tenantId, req.targetDirectoryId);
      if (dir.isNull)
        return notFound("Target directory");
      if (dir.globalAccountId != subaccount.globalAccountId)
        return violation("Subaccounts can only be moved within their global account");
    }

    return guarded(() {
      auto from = subaccount.parentDirectoryId.value;
      subaccount.moveTo(req.targetDirectoryId, actor(req.movedBy));
      repository.update(subaccount);
      recorder.record(tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
        EnvironmentEventCategory.subaccountLifecycle, "subaccount.moved",
        "Subaccount moved: " ~ subaccount.displayName, subaccount.updatedBy, EnvironmentEventSeverity.info,
        ["from": from, "to": req.targetDirectoryId.value]);
      return ok(id.value, "Subaccount moved");
    });
  }

  UsecaseResult suspendSubaccount(TenantId tenantId, SubaccountId id) {
    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.isNull)
      return notFound("Subaccount");
    return guarded(() {
      subaccount.suspend(UserId("system"));
      repository.update(subaccount);
      recorder.record(tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
        EnvironmentEventCategory.subaccountLifecycle, "subaccount.suspended",
        "Subaccount suspended: " ~ subaccount.displayName, subaccount.updatedBy, EnvironmentEventSeverity.warning);
      return ok(id.value, "Subaccount suspended");
    });
  }

  UsecaseResult reactivateSubaccount(TenantId tenantId, SubaccountId id) {
    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.isNull)
      return notFound("Subaccount");
    return guarded(() {
      subaccount.reactivate(UserId("system"));
      repository.update(subaccount);
      recorder.record(tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
        EnvironmentEventCategory.subaccountLifecycle, "subaccount.reactivated",
        "Subaccount reactivated: " ~ subaccount.displayName, subaccount.updatedBy);
      return ok(id.value, "Subaccount reactivated");
    });
  }

  Subaccount getSubaccount(TenantId tenantId, SubaccountId id) {
    return repository.findById(tenantId, id);
  }

  Subaccount[] listSubaccounts(TenantId tenantId) {
    return repository.findByTenant(tenantId);
  }

  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId) {
    return repository.findByGlobalAccount(tenantId, gaId);
  }

  Subaccount[] listSubaccounts(TenantId tenantId, DirectoryId dirId) {
    return repository.findByDirectory(tenantId, dirId);
  }

  Subaccount[] listSubaccounts(TenantId tenantId, GlobalAccountId gaId, string region) {
    return repository.findByRegion(tenantId, gaId, region);
  }

  UsecaseResult deleteSubaccount(TenantId tenantId, SubaccountId id) {
    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.isNull)
      return notFound("Subaccount");
    if (subaccount.status == SubaccountStatus.deleting)
      return violation("Subaccount is already being deleted");
    if (environments.findBySubaccount(tenantId, id).any!(e => e.isLive))
      return violation("Deprovision all environments of subaccount '" ~ subaccount.displayName ~ "' first");
    if (subscriptions.findBySubaccount(tenantId, id).any!(s => s.isLive))
      return violation("Unsubscribe all applications of subaccount '" ~ subaccount.displayName ~ "' first");

    repository.remove(subaccount);
    recorder.record(tenantId, PlatformEventRecorder.ofSubaccount(subaccount),
      EnvironmentEventCategory.subaccountLifecycle, "subaccount.deleted",
      "Subaccount deleted: " ~ subaccount.displayName, UserId("system"), EnvironmentEventSeverity.warning);
    return ok(id.value, "Subaccount deleted");
  }
}
