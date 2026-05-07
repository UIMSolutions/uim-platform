/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.entitlements;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.ports.repositories.entitlements;
// import uim.platform.management.domain.services.entitlement_evaluator;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage service plan entitlements and quota assignments.
class ManageEntitlementsUseCase { // TODO: UIMUseCase {
  private EntitlementRepository repo;
  private EntitlementEvaluator evaluator;

  this(EntitlementRepository repo, EntitlementEvaluator evaluator) {
    this.repo = repo;
    this.evaluator = evaluator;
  }

  CommandResult assign(AssignEntitlementRequest request) {
    if (request.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (request.servicePlanId.isEmpty)
      return CommandResult(false, "", "Service plan ID is required");
    if (request.serviceName.length == 0)
      return CommandResult(false, "", "Service name is required");

    // Check current quota usage for this plan in the global account
    auto existing = repo.findByServicePlan(request.globalAccountId, request.servicePlanId);
    int currentlyAssigned = 0;
    foreach (e; existing)
      currentlyAssigned += e.quotaAssigned;

    Entitlement ent;
    ent.id = randomUUID();
    ent.globalAccountId = request.globalAccountId;
    ent.directoryId = request.directoryId;
    ent.subaccountId = request.subaccountId;
    ent.servicePlanId = request.servicePlanId;
    ent.serviceName = request.serviceName;
    ent.planName = request.planName;
    ent.quotaAssigned = request.quotaAssigned;
    ent.quotaRemaining = request.quotaAssigned;
    ent.unlimited = request.unlimited;
    ent.autoAssign = request.autoAssign;
    ent.status = EntitlementStatus.active;
    ent.assignedAt = clockSeconds();
    ent.updatedAt = ent.assignedAt;
    ent.assignedBy = request.assignedBy;

    repo.save(ent);
    return CommandResult(true, ent.id.value, "");
  }

  CommandResult updateQuota(string id, UpdateEntitlementQuotaRequest request) {
    return updateQuota(EntitlementId(id), request);
  }

  CommandResult updateQuota(EntitlementId id, UpdateEntitlementQuotaRequest request) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Entitlement not found");

    auto ent = repo.findById(tenantId, id);
    ent.quotaAssigned = request.quotaAssigned;
    ent.unlimited = request.unlimited;
    ent.quotaRemaining = evaluator.calculateRemaining(request.quotaAssigned, ent.quotaUsed);
    ent.updatedAt = clockSeconds();
    repo.update(ent);
    return CommandResult(true, ent.id.value, "");
  }

  CommandResult revoke(string id) {
    return revoke(EntitlementId(id));
  }

  CommandResult revoke(EntitlementId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Entitlement not found");

    auto ent = repo.findById(tenantId, id);
    ent.status = EntitlementStatus.revoked;
    ent.updatedAt = clockSeconds();
    repo.update(ent);
    return CommandResult(true, ent.id.value, "");
  }

  Entitlement getById(string id) {
    return getById(EntitlementId(id));
  }

  Entitlement getById(EntitlementId id) {
    return repo.findById(tenantId, id);
  }

  Entitlement[] listByGlobalAccount(GlobalAccountId gaId) {
    return repo.findByGlobalAccount(gaId);
  }

  Entitlement[] listBySubaccount(SubaccountId subId) {
    return repo.findBySubaccount(subId);
  }

  Entitlement[] listByDirectory(DirectoryId dirId) {
    return repo.findByDirectory(dirId);
  }

  CommandResult deleteEntitlement(EntitlementId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Entitlement not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
