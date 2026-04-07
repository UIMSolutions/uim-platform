/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.global_accounts;

import uim.platform.management.application.dto;
import uim.platform.management.domain.entities.global_account;
import uim.platform.management.domain.entities.platform_event;
import uim.platform.management.domain.ports.repositories.global_accounts;
import uim.platform.management.domain.ports.repositories.platform_events;
import uim.platform.management.domain.types;

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

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    GlobalAccount ga;
    ga.id = id;
    ga.displayName = req.displayName;
    ga.description = req.description;
    ga.contractNumber = req.contractNumber;
    ga.licenseType = parseLicenseType(req.licenseType);
    ga.region = req.region;
    ga.costCenter = req.costCenter;
    ga.companyName = req.companyName;
    ga.contactEmail = req.contactEmail;
    ga.maxSubaccounts = req.maxSubaccounts > 0 ? req.maxSubaccounts : 100;
    ga.maxDirectories = req.maxDirectories > 0 ? req.maxDirectories : 20;
    ga.createdAt = clockSeconds();
    ga.modifiedAt = ga.createdAt;
    ga.createdBy = req.createdBy;
    ga.customProperties = req.customProperties;

    repo.save(ga);
    emitEvent(id, "", PlatformEventCategory.globalAccountChange,
        "globalAccount.created", "Global account created: " ~ req.displayName, req.createdBy);

    return CommandResult(true, id, "");
  }

  CommandResult update(GlobalAccountId id, UpdateGlobalAccountRequest req) {
    auto ga = repo.findById(id);
    if (ga.id.length == 0)
      return CommandResult(false, "", "Global account not found");

    if (req.displayName.length > 0)
      ga.displayName = req.displayName;
    if (req.description.length > 0)
      ga.description = req.description;
    if (req.costCenter.length > 0)
      ga.costCenter = req.costCenter;
    if (req.contactEmail.length > 0)
      ga.contactEmail = req.contactEmail;
    if (req.customProperties.length > 0)
      ga.customProperties = req.customProperties;
    ga.modifiedAt = clockSeconds();

    repo.update(ga);
    return CommandResult(true, id, "");
  }

  CommandResult suspend(GlobalAccountId id) {
    auto ga = repo.findById(id);
    if (ga.id.length == 0)
      return CommandResult(false, "", "Global account not found");
    if (ga.status != GlobalAccountStatus.active)
      return CommandResult(false, "", "Only active accounts can be suspended");

    ga.status = GlobalAccountStatus.suspended;
    ga.modifiedAt = clockSeconds();
    repo.update(ga);

    emitEvent(id, "", PlatformEventCategory.globalAccountChange,
        "globalAccount.suspended", "Global account suspended", "system");
    return CommandResult(true, id, "");
  }

  CommandResult reactivate(GlobalAccountId id) {
    auto ga = repo.findById(id);
    if (ga.id.length == 0)
      return CommandResult(false, "", "Global account not found");
    if (ga.status != GlobalAccountStatus.suspended)
      return CommandResult(false, "", "Only suspended accounts can be reactivated");

    ga.status = GlobalAccountStatus.active;
    ga.modifiedAt = clockSeconds();
    repo.update(ga);
    return CommandResult(true, id, "");
  }

  GlobalAccount getById(GlobalAccountId id) {
    return repo.findById(id);
  }

  GlobalAccount[] listAll() {
    return repo.findAll();
  }

  GlobalAccount[] listByStatus(string status) {
    return repo.findByStatus(parseGlobalAccountStatus(status));
  }

  CommandResult remove(GlobalAccountId id) {
    auto ga = repo.findById(id);
    if (ga.id.length == 0)
      return CommandResult(false, "", "Global account not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private void emitEvent(string gaId, string subId, PlatformEventCategory cat,
      string eventType, string desc, string initiatedBy) {
    // import std.uuid : randomUUID;

    PlatformEvent ev;
    ev.id = randomUUID().toString();
    ev.globalAccountId = gaId;
    ev.subaccountId = subId;
    ev.category = cat;
    ev.severity = PlatformEventSeverity.info;
    ev.eventType = eventType;
    ev.description = desc;
    ev.initiatedBy = initiatedBy;
    ev.sourceService = "cloud-management";
    ev.timestamp = clockSeconds();
    eventRepo.save(ev);
  }

  private long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / 10_000_000;
  }

  private GlobalAccountStatus parseGlobalAccountStatus(string s) {
    switch (s)
    {
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
    switch (s)
    {
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

private long clockSeconds() {
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
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
