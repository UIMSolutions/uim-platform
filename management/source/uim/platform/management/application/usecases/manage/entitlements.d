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

  CommandResult assignEntitlement(AssignEntitlementRequest request) {
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
    ent.initEntity(request.tenantId, request.assignedBy);

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
    ent.assignedBy = request.assignedBy;

    repo.save(ent);
    return CommandResult(true, ent.id.value, "");
  }

  CommandResult updateEntitlementQuota(UpdateEntitlementQuotaRequest request) {
    auto ent = repo.findById(request.tenantId, request.id);
    if (ent.isNull)
      return CommandResult(false, "", "Entitlement not found");

    ent.quotaAssigned = request.quotaAssigned;
    ent.unlimited = request.unlimited;
    ent.quotaRemaining = evaluator.calculateRemaining(request.quotaAssigned, ent.quotaUsed);
    ent.updatedAt = clockSeconds();

    repo.update(ent);
    return CommandResult(true, ent.id.value, "");
  }

  CommandResult revokeEntitlement(TenantId tenantId, EntitlementId id) {
    auto ent = repo.findById(tenantId, id);
    if (ent.isNull)
      return CommandResult(false, "", "Entitlement not found");

    ent.status = EntitlementStatus.revoked;
    ent.updatedAt = clockSeconds();

    repo.update(ent);
    return CommandResult(true, ent.id.value, "");
  }

  Entitlement getEntitlement(TenantId tenantId, EntitlementId id) {
    return repo.findById(tenantId, id);
  }

  Entitlement[] listEntitlements(TenantId tenantId, GlobalAccountId gaId) {
    return repo.findByGlobalAccount(tenantId, gaId);
  }

  Entitlement[] listEntitlements(TenantId tenantId, SubaccountId subId) {
    return repo.findBySubaccount(tenantId, subId);
  }

  Entitlement[] listEntitlements(TenantId tenantId, DirectoryId dirId) {
    return repo.findByDirectory(tenantId, dirId);
  }

  CommandResult deleteEntitlement(TenantId tenantId, EntitlementId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Entitlement not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
