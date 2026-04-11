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
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage global account lifecycle.
class ManageGlobalAccountsUseCase : UIMUseCase {
  private GlobalAccountRepository repo;
  private PlatformEventRepository eventRepo;

  this(GlobalAccountRepository repo, PlatformEventRepository eventRepo) {
    this.repo = repo;
    this.eventRepo = eventRepo;
  }

  CommandResult create(CreateGlobalAccountRequest req) {
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    GlobalAccount globalAccount;
    globalAccount.globalAccountId = randomUUID();
    globalAccount.displayName = req.displayName;
    globalAccount.description = req.description;
    globalAccount.contractNumber = req.contractNumber;
    globalAccount.licenseType = parseLicenseType(req.licenseType);
    globalAccount.region = req.region;
    globalAccount.costCenter = req.costCenter;
    globalAccount.companyName = req.companyName;
    globalAccount.contactEmail = req.contactEmail;
    globalAccount.maxSubaccounts = req.maxSubaccounts > 0 ? req.maxSubaccounts : 100;
    globalAccount.maxDirectories = req.maxDirectories > 0 ? req.maxDirectories : 20;
    globalAccount.createdAt = clockSeconds();
    globalAccount.modifiedAt = globalAccount.createdAt;
    globalAccount.createdBy = req.createdBy;
    globalAccount.customProperties = req.customProperties;

    repo.save(globalAccount);
    emitEvent(eventRepo, globalAccount.globalAccountId.toString, "", PlatformEventCategory.globalAccountChange,
        "globalAccount.created", "Global account created: " ~ req.displayName, req.createdBy);

    return CommandResult(true, globalAccount.globalAccountId.toString, "");
  }

  CommandResult update(string id, UpdateGlobalAccountRequest req) {
    return update(GlobalAccountId(id), req);
  }

  CommandResult update(GlobalAccountId id, UpdateGlobalAccountRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Global account not found");

    auto globalAccount = repo.findById(id);
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
    globalAccount.modifiedAt = clockSeconds();

    repo.update(globalAccount);
    return CommandResult(true, id.toString, "");
  }

  CommandResult suspend(string id) {
    return suspend(GlobalAccountId(id));
  }

  CommandResult suspend(GlobalAccountId accountId) {
    if (!repo.existsById(accountId))
      return CommandResult(false, "", "Global account not found");

    auto globalAccount = repo.findById(accountId);
    if (globalAccount.status != GlobalAccountStatus.active)
      return CommandResult(false, "", "Only active accounts can be suspended");

    globalAccount.status = GlobalAccountStatus.suspended;
    globalAccount.modifiedAt = clockSeconds();
    repo.update(globalAccount);

    emitEvent(eventRepo, accountId.toString, "", PlatformEventCategory.globalAccountChange,
        "globalAccount.suspended", "Global account suspended", "system");
    return CommandResult(true, accountId.toString, "");
  }
  
  CommandResult reactivate(string id) {
    return reactivate(GlobalAccountId(id));
  }

  CommandResult reactivate(GlobalAccountId accountId) {
    if (!repo.existsById(accountId))
      return CommandResult(false, "", "Global account not found");

    auto globalAccount = repo.findById(accountId);
    if (globalAccount.status != GlobalAccountStatus.suspended)
      return CommandResult(false, "", "Only suspended accounts can be reactivated");

    globalAccount.status = GlobalAccountStatus.active;
    globalAccount.modifiedAt = clockSeconds();
    repo.update(globalAccount);
    return CommandResult(true, accountId.toString, "");
  }

  bool existsById(string id) {
    return existsById(GlobalAccountId(id));
  }

  bool existsById(GlobalAccountId accountId) {
    return repo.existsById(accountId);
  }

  GlobalAccount getById(string id) {
    return getById(GlobalAccountId(id));
  }

  GlobalAccount getById(GlobalAccountId accountId) {
    return repo.findById(accountId);
  }

  GlobalAccount[] listAll() {
    return repo.findAll();
  }

  GlobalAccount[] listByStatus(string status) {
    return repo.findByStatus(parseGlobalAccountStatus(status));
  }

  CommandResult remove(string id) {
    return remove(GlobalAccountId(id));
  }

  CommandResult remove(GlobalAccountId accountId) {
    if (!repo.existsById(accountId))
      return CommandResult(false, "", "Global account not found");

    repo.remove(accountId);
    return CommandResult(true, accountId.toString, "");
  }





  private GlobalAccountStatus parseGlobalAccountStatus(string s) {
    switch (s) {
    case "active":
      return GlobalAccountStatus.active;
    case "suspended":
      return GlobalAccountStatus.suspended;
    case "terminated":
      return GlobalAccountStatus.terminated;
    case "migrating":
      return GlobalAccountStatus.migrating;
    default:
      return GlobalAccountStatus.active;
    }
  }

  private LicenseType parseLicenseType(string s) {
    switch (s) {
    case "enterprise":
      return LicenseType.enterprise;
    case "trial":
      return LicenseType.trial;
    case "partner":
      return LicenseType.partner;
    case "internal":
      return LicenseType.internal;
    default:
      return LicenseType.enterprise;
    }
  }
}



private LicenseType parseLicenseType(string s) {
  switch (s) {
  case "enterprise":
    return LicenseType.enterprise;
  case "trial":
    return LicenseType.trial;
  case "partner":
    return LicenseType.partner;
  case "internal":
    return LicenseType.internal;
  default:
    return LicenseType.enterprise;
  }
}
