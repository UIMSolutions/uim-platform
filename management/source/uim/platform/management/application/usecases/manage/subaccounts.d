/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.subaccounts;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.subaccount;
// import uim.platform.management.domain.entities.platform_event;
// import uim.platform.management.domain.ports.repositories.subaccounts;
// import uim.platform.management.domain.ports.repositories.platform_events;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage subaccount lifecycle within global accounts.
class ManageSubaccountsUseCase { // TODO: UIMUseCase {
  private SubaccountRepository repository;
  private PlatformEventRepository eventRepo;

  this(SubaccountRepository repository, PlatformEventRepository eventRepo) {
    this.repository = repository;
    this.eventRepo = eventRepo;
  }

  CommandResult create(CreateSubaccountRequest req) {
    if (req.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");
    if (req.subdomain.length == 0)
      return CommandResult(false, "", "Subdomain is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    // Check subdomain uniqueness
    if (repository.existsBySubdomain(req.subdomain))
      return CommandResult(false, "", "Subdomain '" ~ req.subdomain ~ "' is already taken");

    Subaccount subaccount;
    subaccount.id = randomUUID();
    subaccount.globalAccountId = req.globalAccountId;
    subaccount.parentDirectoryId = req.parentDirectoryId;
    subaccount.displayName = req.displayName;
    subaccount.description = req.description;
    subaccount.subdomain = req.subdomain;
    subaccount.region = req.region;
    subaccount.usage = parseUsage(req.usage);
    subaccount.betaEnabled = req.betaEnabled;
    subaccount.usedForProduction = req.usedForProduction;
    subaccount.status = SubaccountStatus.creating;
    subaccount.createdAt = clockSeconds();
    subaccount.updatedAt = subaccount.createdAt;
    subaccount.createdBy = req.createdBy;
    subaccount.labels = req.labels;
    subaccount.customProperties = req.customProperties;

    repository.save(subaccount);

    // Transition to active
    subaccount.status = SubaccountStatus.active;
    repository.update(subaccount);

    emitEvent(req.globalAccountId.toString, subaccount.id.toString, PlatformEventCategory.subaccountLifecycle,
        "subaccount.created", "Subaccount created: " ~ req.displayName, req.createdBy);

    return CommandResult(true, subaccount.id.toString, "");
  }

  CommandResult update(string id, UpdateSubaccountRequest req) {
    return update(SubaccountId(id), req);
  }

  CommandResult update(SubaccountId id, UpdateSubaccountRequest req) {
    if (!repository.existsById(id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(id);
    if (req.displayName.length > 0)
      subaccount.displayName = req.displayName;
    if (req.description.length > 0)
      subaccount.description = req.description;
    if (req.usage.length > 0)
      subaccount.usage = parseUsage(req.usage);
    subaccount.betaEnabled = req.betaEnabled;
    subaccount.usedForProduction = req.usedForProduction;
    if (req.labels.length > 0)
      subaccount.labels = req.labels;
    if (req.customProperties.length > 0)
      subaccount.customProperties = req.customProperties;
    subaccount.updatedAt = clockSeconds();

    repository.update(subaccount);
    return CommandResult(true, id.toString, "");
  }

  CommandResult moveSubaccount(string id, MoveSubaccountRequest req) {
    return moveSubaccount(SubaccountId(id), req);
  }

  CommandResult moveSubaccount(SubaccountId id, MoveSubaccountRequest req) {
    if (!repository.existsById(id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(id);
    if (subaccount.status != SubaccountStatus.active)
      return CommandResult(false, "", "Subaccount must be active to move");

    subaccount.status = SubaccountStatus.moveInProgress;
    subaccount.parentDirectoryId = req.targetDirectoryId;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);

    // Complete move
    subaccount.status = SubaccountStatus.active;
    repository.update(subaccount);
    return CommandResult(true, id.toString, "");
  }

  CommandResult suspend(string id) {
    return suspend(SubaccountId(id));
  }

  CommandResult suspend(SubaccountId id) {
    if (!repository.existsById(id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(id);
    if (subaccount.status != SubaccountStatus.active)
      return CommandResult(false, "", "Only active subaccounts can be suspended");

    subaccount.status = SubaccountStatus.suspended;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);
    return CommandResult(true, id.toString, "");
  }

  CommandResult reactivate(string id) {
    return reactivate(SubaccountId(id));
  }

  CommandResult reactivate(SubaccountId id) {
    if (!repository.existsById(id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(id);
    if (subaccount.status != SubaccountStatus.suspended)
      return CommandResult(false, "", "Only suspended subaccounts can be reactivated");

    subaccount.status = SubaccountStatus.active;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);
    return CommandResult(true, id.toString, "");
  }

  Subaccount getById(string id) {
    return getById(SubaccountId(id));
  }

  Subaccount getById(SubaccountId id) {
    return repository.findById(id);
  }

  Subaccount[] listByGlobalAccount(string gaId) {
    return listByGlobalAccount(GlobalAccountId(gaId));
  }

  Subaccount[] listByGlobalAccount(GlobalAccountId gaId) {
    return repository.findByGlobalAccount(gaId);
  }

  Subaccount[] listByDirectory(string dirId) {
    return listByDirectory(DirectoryId(dirId));
  }

  Subaccount[] listByDirectory(DirectoryId dirId) {
    return repository.findByDirectory(dirId);
  }

  Subaccount[] listByRegion(string gaId, string region) {
    return listByRegion(GlobalAccountId(gaId), region);
  }

  Subaccount[] listByRegion(GlobalAccountId gaId, string region) {
    return repository.findByRegion(gaId, region);
  }

  CommandResult remove(string id) {
    return remove(SubaccountId(id));
  }

  CommandResult remove(SubaccountId id) {
    if (!repository.existsById(id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(id);
    repository.removeById(id);
    emitEvent(subaccount.globalAccountId.toString, id.toString, PlatformEventCategory.subaccountLifecycle,
        "subaccount.deleted", "Subaccount deleted: " ~ subaccount.displayName, UserId("system"));
    return CommandResult(true, id.toString, "");
  }

  private void emitEvent(string gaId, string subId, PlatformEventCategory cat,
      string eventType, string desc, UserId initiatedBy) {

    PlatformEvent event;
    event.id = randomUUID();
    event.globalAccountId = gaId;
    event.subaccountId = subId;
    event.category = cat;
    event.severity = PlatformEventSeverity.info;
    event.eventType = eventType;
    event.description = desc;
    event.initiatedBy = initiatedBy;
    event.sourceService = "cloud-management";
    event.timestamp = clockSeconds();
    eventRepo.save(event);
  }

  private SubaccountUsage parseUsage(string usage) {
    switch (usage) {
    case "production":
      return SubaccountUsage.production;
    case "development":
      return SubaccountUsage.development;
    case "test":
      return SubaccountUsage.test;
    case "staging":
      return SubaccountUsage.staging;
    case "demo":
      return SubaccountUsage.demo;
    default:
      return SubaccountUsage.unset;
    }
  }
}
