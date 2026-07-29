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

import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Use case: manage service plan entitlements and quota assignments.
class ManageEntitlementsUseCase { // TODO: UIMUseCase {
  private IEntitlementRepository repo;
  private EntitlementEvaluator evaluator;

  this(IEntitlementRepository repo, EntitlementEvaluator evaluator) {
    this.repo = repo;
    this.evaluator = evaluator;
  }

  CommandResult assignEntitlement(AssignEntitlementRequest request) {
    if (request.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (request.servicePlanId.isEmpty)
      return CommandResult(false, "", "Service plan ID is required");
    if (request.serviceName.isEmpty)
      return CommandResult(false, "", "Service name is required");

    // Check current quota usage for this plan in the global account
    auto existing = repo.findByServicePlan(request.tenantId, request.globalAccountId, request.servicePlanId);
    int currentlyAssigned = 0;
    foreach (e; existing)
      currentlyAssigned += e.quotaAssigned;

    auto entitlement = Entitlement(request.tenantId);
    entitlement.globalAccountId = request.globalAccountId;
    entitlement.directoryId = request.directoryId;
    entitlement.subaccountId = request.subaccountId;
    entitlement.servicePlanId = request.servicePlanId;
    entitlement.serviceName = request.serviceName;
    entitlement.planName = request.planName;
    entitlement.quotaAssigned = request.quotaAssigned;
    entitlement.quotaRemaining = request.quotaAssigned;
    entitlement.unlimited = request.unlimited;
    entitlement.autoAssign = request.autoAssign;
    entitlement.status = EntitlementStatus.active;
    entitlement.assignedAt = clockSeconds();
    entitlement.assignedBy = request.assignedBy;

    repo.save(entitlement);
    return CommandResult(true, entitlement.id.value, "");
  }

  CommandResult updateEntitlementQuota(UpdateEntitlementQuotaRequest request) {
    auto ent = repo.findById(request.tenantId, request.entitlementId);
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

///
unittest {
    auto entitlementRepository = new EntitlementRepository();
    auto entitlementEvaluator = new EntitlementEvaluator();
    auto usecase = new ManageEntitlementsUseCase(entitlementRepository, entitlementEvaluator);
    auto tenantId = TenantId("test-tenant");

}
