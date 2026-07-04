/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.global_accounts;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.global_account;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.global_accounts;
// import uim.platform.management.domain.ports.repositories.platform_events;

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage global account lifecycle.
class ManageGlobalAccountsUseCase { // TODO: UIMUseCase {
  private GlobalAccountRepository repo;
  private EnvironmentEventRepository eventRepo;

  this(GlobalAccountRepository repo, EnvironmentEventRepository eventRepo) {
    this.repo = repo;
    this.eventRepo = eventRepo;
  }

  CommandResult createAccount(CreateGlobalAccountRequest req) {
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    auto globalAccount = GlobalAccount(req.tenantId); //, req.createdBy);
    globalAccount.displayName = req.displayName;
    globalAccount.description = req.description;
    globalAccount.contractNumber = req.contractNumber;
    globalAccount.licenseType = req.licenseType.to!LicenseType;
    globalAccount.region = req.region;
    globalAccount.costCenter = req.costCenter;
    globalAccount.companyName = req.companyName;
    globalAccount.contactEmail = req.contactEmail;
    globalAccount.maxSubaccounts = req.maxSubaccounts > 0 ? req.maxSubaccounts : 100;
    globalAccount.maxDirectories = req.maxDirectories > 0 ? req.maxDirectories : 20;
    globalAccount.customProperties = req.customProperties;

    repo.save(globalAccount);
    emitEvent(eventRepo, globalAccount.id.value, "", EnvironmentEventCategory.globalAccountChange,
      "globalAccount.created", "Global account created: " ~ req.displayName, req.createdBy);

    return CommandResult(true, globalAccount.id.value, "");
  }

  CommandResult updateAccount(UpdateGlobalAccountRequest req) {
    auto globalAccount = repo.findById(req.tenantId, req.accountId);
    if (globalAccount.isNull)
      return CommandResult(false, "", "Global account not found");

    if (req.displayName.length > 0)
      globalAccount.displayName = req.displayName;
    if (req.description.length > 0)
      globalAccount.description = req.description;
    if (req.costCenter.length > 0)
      globalAccount.costCenter = req.costCenter;
    if (req.contactEmail.length > 0)
      globalAccount.contactEmail = req.contactEmail;
    if (req.customProperties.length > 0)
      globalAccount.customProperties = req.customProperties;
    globalAccount.updatedAt = clockSeconds();

    repo.update(globalAccount);
    return CommandResult(true, globalAccount.id.value, "");
  }

  CommandResult suspendAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto globalAccount = repo.findById(tenantId, accountId);
    if (globalAccount.isNull)
      return CommandResult(false, "", "Global account not found");

    if (globalAccount.status != GlobalAccountStatus.active)
      return CommandResult(false, "", "Only active accounts can be suspended");

    globalAccount.status = GlobalAccountStatus.suspended;
    globalAccount.updatedAt = clockSeconds();
    repo.update(globalAccount);

    emitEvent(eventRepo, accountId.value, "", EnvironmentEventCategory.globalAccountChange,
      "globalAccount.suspended", "Global account suspended", UserId("system"));
    return CommandResult(true, accountId.value, "");
  }

  CommandResult reactivateAccount(TenantId tenantId,  GlobalAccountId accountId) {
    auto globalAccount = repo.findById(tenantId, accountId);
    if (globalAccount.isNull)
      return CommandResult(false, "", "Global account not found");

    if (globalAccount.status != GlobalAccountStatus.suspended)
      return CommandResult(false, "", "Only suspended accounts can be reactivated");

    globalAccount.status = GlobalAccountStatus.active;
    globalAccount.updatedAt = clockSeconds();

    repo.update(globalAccount);
    emitEvent(eventRepo, accountId.value, "", EnvironmentEventCategory.globalAccountChange,
      "globalAccount.reactivated", "Global account reactivated", UserId("system")); 
    return CommandResult(true, accountId.value, "");
  }

  bool existsAccount(TenantId tenantId, GlobalAccountId accountId) {
    return repo.existsById(tenantId, accountId);
  }

  GlobalAccount getAccount(TenantId tenantId, GlobalAccountId accountId) {
    return repo.findById(tenantId, accountId);
  }

  GlobalAccount[] listAccounts(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  GlobalAccount[] listAccounts(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, status.to!GlobalAccountStatus);
  }

  CommandResult deleteAccount(TenantId tenantId, GlobalAccountId accountId) {
    auto entity = repo.findById(tenantId, accountId);
    if (entity.isNull)
      return CommandResult(false, "", "Global account not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

}
