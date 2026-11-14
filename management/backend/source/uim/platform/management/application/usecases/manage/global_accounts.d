/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.global_accounts;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage global account lifecycle.
class ManageGlobalAccountsUseCase : IManageGlobalAccountsUseCase {
  protected IGlobalAccountRepository repo;
  protected ISubaccountRepository subaccounts;
  protected IDirectoryRepository directories;
  protected PlatformEventRecorder recorder;

  this(IGlobalAccountRepository repo, ISubaccountRepository subaccounts,
      IDirectoryRepository directories, PlatformEventRecorder recorder) {
    this.repo = repo;
    this.subaccounts = subaccounts;
    this.directories = directories;
    this.recorder = recorder;
  }

  UsecaseResult createAccount(CreateGlobalAccountRequest req) {
    if (req.displayName.length == 0)
      return invalid("Display name is required");
    if (req.region.length == 0)
      return invalid("Region is required");
    if (req.maxSubaccounts < 0 || req.maxDirectories < 0)
      return invalid("Limits must not be negative");
    LicenseType license;
    if (req.licenseType.length > 0 && !tryParseEnum!LicenseType(req.licenseType, license))
      return invalid("Unknown license type '" ~ req.licenseType ~ "' (expected " ~ enumNames!LicenseType().join(", ") ~ ")");

    auto ga = GlobalAccount(req.tenantId);
    ga.displayName = req.displayName;
    ga.description = req.description;
    ga.contractNumber = req.contractNumber;
    ga.licenseType = req.licenseType.length > 0 ? license : LicenseType.enterprise;
    ga.region = req.region;
    ga.costCenter = req.costCenter;
    ga.companyName = req.companyName;
    ga.contactEmail = req.contactEmail;
    ga.maxSubaccounts = req.maxSubaccounts > 0 ? req.maxSubaccounts : 100;
    ga.maxDirectories = req.maxDirectories > 0 ? req.maxDirectories : 20;
    ga.customProperties = req.customProperties;
    ga.createdBy = actor(req.createdBy);
    ga.updatedBy = ga.createdBy;

    repo.save(ga);
    recorder.record(req.tenantId, PlatformEventRecorder.ofGlobalAccount(ga),
      EnvironmentEventCategory.globalAccountChange, "globalAccount.created",
      "Global account created: " ~ ga.displayName, ga.createdBy);
    return created(ga.id.value, "Global account created");
  }

  UsecaseResult updateAccount(UpdateGlobalAccountRequest req) {
    auto ga = repo.findById(req.tenantId, req.accountId);
    if (ga.isNull)
      return notFound("Global account");

    if (req.displayName.length > 0)
      ga.displayName = req.displayName;
    if (req.description.length > 0)
      ga.description = req.description;
    if (req.costCenter.length > 0)
      ga.costCenter = req.costCenter;
    if (req.contactEmail.length > 0)
      ga.contactEmail = req.contactEmail;
    if (req.companyName.length > 0)
      ga.companyName = req.companyName;
    if (req.customProperties.length > 0)
      ga.customProperties = req.customProperties;

    // Limits may not drop below what is already in use.
    if (req.maxSubaccounts > 0) {
      auto used = subaccounts.findByGlobalAccount(req.tenantId, ga.id).length;
      if (req.maxSubaccounts < used)
        return violation("Global account already has " ~ used.to!string ~ " subaccounts");
      ga.maxSubaccounts = req.maxSubaccounts;
    }
    if (req.maxDirectories > 0) {
      auto used = directories.findByGlobalAccount(req.tenantId, ga.id).length;
      if (req.maxDirectories < used)
        return violation("Global account already has " ~ used.to!string ~ " directories");
      ga.maxDirectories = req.maxDirectories;
    }
    ga.update(actor(req.updatedBy));

    repo.update(ga);
    recorder.record(req.tenantId, PlatformEventRecorder.ofGlobalAccount(ga),
      EnvironmentEventCategory.globalAccountChange, "globalAccount.updated",
      "Global account updated: " ~ ga.displayName, ga.updatedBy);
    return ok(ga.id.value, "Global account updated");
  }

  UsecaseResult suspendAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto ga = repo.findById(tenantId, accountId);
    if (ga.isNull)
      return notFound("Global account");
    return guarded(() {
      ga.suspend(UserId("system"));
      repo.update(ga);
      recorder.record(tenantId, PlatformEventRecorder.ofGlobalAccount(ga),
        EnvironmentEventCategory.globalAccountChange, "globalAccount.suspended",
        "Global account suspended: " ~ ga.displayName, ga.updatedBy, EnvironmentEventSeverity.warning);
      return ok(ga.id.value, "Global account suspended");
    });
  }

  UsecaseResult reactivateAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto ga = repo.findById(tenantId, accountId);
    if (ga.isNull)
      return notFound("Global account");
    return guarded(() {
      ga.reactivate(UserId("system"));
      repo.update(ga);
      recorder.record(tenantId, PlatformEventRecorder.ofGlobalAccount(ga),
        EnvironmentEventCategory.globalAccountChange, "globalAccount.reactivated",
        "Global account reactivated: " ~ ga.displayName, ga.updatedBy);
      return ok(ga.id.value, "Global account reactivated");
    });
  }

  bool existsAccount(TenantId tenantId, GlobalAccountId accountId) {
    return repo.existsById(tenantId, accountId);
  }

  GlobalAccount getAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto ga = repo.findById(tenantId, accountId);
    if (!ga.isNull)
      withCounters(ga);
    return ga;
  }

  GlobalAccount[] listAccounts(TenantId tenantId) {
    auto items = repo.findByTenant(tenantId);
    foreach (ref ga; items)
      withCounters(ga);
    return items;
  }

  GlobalAccount[] listAccounts(TenantId tenantId, string status) {
    GlobalAccountStatus s;
    if (!tryParseEnum!GlobalAccountStatus(status, s))
      return null;
    auto items = repo.findByStatus(tenantId, s);
    foreach (ref ga; items)
      withCounters(ga);
    return items;
  }

  UsecaseResult deleteAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto ga = repo.findById(tenantId, accountId);
    if (ga.isNull)
      return notFound("Global account");
    if (subaccounts.findByGlobalAccount(tenantId, accountId).length > 0
        || directories.findByGlobalAccount(tenantId, accountId).length > 0)
      return violation("Delete all subaccounts and directories of global account '" ~ ga.displayName ~ "' first");

    repo.remove(ga);
    recorder.record(tenantId, PlatformEventRecorder.ofGlobalAccount(ga),
      EnvironmentEventCategory.globalAccountChange, "globalAccount.deleted",
      "Global account deleted: " ~ ga.displayName, UserId("system"), EnvironmentEventSeverity.warning);
    return ok(ga.id.value, "Global account deleted");
  }

  /// The current* counters are derived from the repositories (never stored stale).
  protected void withCounters(ref GlobalAccount ga) {
    ga.currentSubaccounts = cast(int) subaccounts.findByGlobalAccount(ga.tenantId, ga.id).length;
    ga.currentDirectories = cast(int) directories.findByGlobalAccount(ga.tenantId, ga.id).length;
  }
}
