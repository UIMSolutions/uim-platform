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

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage subaccount lifecycle within global accounts.
class ManageSubaccountsUseCase { // TODO: UIMUseCase {
  private SubaccountRepository repository;
  private EnvironmentEventRepository eventRepo;

  this(SubaccountRepository repository, EnvironmentEventRepository eventRepo) {
    this.repository = repository;
    this.eventRepo = eventRepo;
  }

  CommandResult createSubaccount(CreateSubaccountRequest req) {
    if (req.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");
    if (req.subdomain.length == 0)
      return CommandResult(false, "", "Subdomain is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    // Check subdomain uniqueness
    if (repository.existsBySubdomain(req.tenantId, req.subdomain))
      return CommandResult(false, "", "Subdomain '" ~ req.subdomain ~ "' is already taken");

    Subaccount subaccount;
    subaccount.initEntity(req.tenantId);

    subaccount.globalAccountId = req.globalAccountId;
    subaccount.parentDirectoryId = req.parentDirectoryId;
    subaccount.displayName = req.displayName;
    subaccount.description = req.description;
    subaccount.subdomain = req.subdomain;
    subaccount.region = req.region;
    subaccount.usage = toSubaccountUsage(req.usage);
    subaccount.betaEnabled = req.betaEnabled;
    subaccount.usedForProduction = req.usedForProduction;
    subaccount.status = SubaccountStatus.creating;
    subaccount.labels = req.labels;
    subaccount.customProperties = req.customProperties;
    subaccount.createdBy = req.createdBy;
    subaccount.updatedBy = req.createdBy;

    repository.save(subaccount);

    // Transition to active
    subaccount.status = SubaccountStatus.active;
    repository.update(subaccount);

    emitEvent(subaccount.tenantId, subaccount.globalAccountId.value, subaccount.id.value, EnvironmentEventCategory.subaccountLifecycle,
        "subaccount.created", "Subaccount created: " ~ req.displayName, req.createdBy);

    return CommandResult(true, subaccount.id.value, "");
  }

  CommandResult updateSubaccount(UpdateSubaccountRequest req) {
    auto subaccount = repository.findById(req.tenantId, req.subaccountId);
    if (subaccount.isNull)
      return CommandResult(false, "", "Subaccount not found");

    if (req.displayName.length > 0)
        subaccount.displayName = req.displayName;
      if (req.description.length > 0)
      subaccount.description = req.description;
    if (req.usage.length > 0)
      subaccount.usage = toSubaccountUsage(req.usage);
    subaccount.betaEnabled = req.betaEnabled;
    subaccount.usedForProduction = req.usedForProduction;
    if (req.labels.length > 0)
      subaccount.labels = req.labels;
    if (req.customProperties.length > 0)
      subaccount.customProperties = req.customProperties;
    subaccount.updatedAt = clockSeconds();

    repository.update(subaccount);
    return CommandResult(true, subaccount.id.value, "");
  }

  CommandResult moveSubaccount(TenantId tenantId, SubaccountId id, MoveSubaccountRequest req) {
    if (!repository.existsById(tenantId, id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.status != SubaccountStatus.active)
      return CommandResult(false, "", "Subaccount must be active to move");

    subaccount.status = SubaccountStatus.moveInProgress;
    subaccount.parentDirectoryId = req.targetDirectoryId;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);

    // Complete move
    subaccount.status = SubaccountStatus.active;
    repository.update(subaccount);
    return CommandResult(true, id.value, "");
  }

  CommandResult suspendSubaccount(TenantId tenantId, SubaccountId id) {
    if (!repository.existsById(tenantId, id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.status != SubaccountStatus.active)
      return CommandResult(false, "", "Only active subaccounts can be suspended");

    subaccount.status = SubaccountStatus.suspended;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);
    return CommandResult(true, id.value, "");
  }

  CommandResult reactivateSubaccount(TenantId tenantId, SubaccountId id) {
    if (!repository.existsById(tenantId, id))
      return CommandResult(false, "", "Subaccount not found");

    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.status != SubaccountStatus.suspended)
      return CommandResult(false, "", "Only suspended subaccounts can be reactivated");

    subaccount.status = SubaccountStatus.active;
    subaccount.updatedAt = clockSeconds();
    repository.update(subaccount);
    return CommandResult(true, id.value, "");
  }

  Subaccount getSubaccount(TenantId tenantId, SubaccountId id) {
    return repository.findById(tenantId, id);
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

  CommandResult deleteSubaccount(TenantId tenantId, SubaccountId id) {
    auto subaccount = repository.findById(tenantId, id);
    if (subaccount.isNull)
      return CommandResult(false, "", "Subaccount not found");

    if (subaccount.status == SubaccountStatus.deleting)
      return CommandResult(false, "", "Subaccount is already being deleted");

    repository.remove(subaccount);
    emitEvent(tenantId, subaccount.globalAccountId.value, id.value, EnvironmentEventCategory.subaccountLifecycle,
        "subaccount.deleted", "Subaccount deleted: " ~ subaccount.displayName, UserId("system"));
    return CommandResult(true, id.value, "");
  }

  private void emitEvent(TenantId tenantId, string gaId, string subId, EnvironmentEventCategory cat,
      string eventType, string desc, UserId initiatedBy) {

    EnvironmentEvent event;
    event.initEntity(tenantId);

    event.globalAccountId = gaId;
    event.subaccountId = subId;
    event.category = cat;
    event.severity = EnvironmentEventSeverity.info;
    event.eventType = eventType;
    event.description = desc;
    event.initiatedBy = initiatedBy;
    event.sourceService = "cloud-management";
    event.timestamp = event.createdAt;
    
    eventRepo.save(event);
  }
}
