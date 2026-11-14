/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.entitlements;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage service plan entitlements and quota assignments.
class ManageEntitlementsUseCase : IManageEntitlementsUseCase {
  protected IEntitlementRepository repo;
  protected IServicePlanRepository plans;
  protected IGlobalAccountRepository globalAccounts;
  protected ISubaccountRepository subaccounts;
  protected IDirectoryRepository directories;
  protected EntitlementEvaluator evaluator;
  protected PlatformEventRecorder recorder;

  this(IEntitlementRepository repo, IServicePlanRepository plans, IGlobalAccountRepository globalAccounts,
      ISubaccountRepository subaccounts, IDirectoryRepository directories,
      EntitlementEvaluator evaluator, PlatformEventRecorder recorder) {
    this.repo = repo;
    this.plans = plans;
    this.globalAccounts = globalAccounts;
    this.subaccounts = subaccounts;
    this.directories = directories;
    this.evaluator = evaluator;
    this.recorder = recorder;
  }

  UsecaseResult assignEntitlement(AssignEntitlementRequest request) {
    auto tenant = request.tenantId;
    if (request.servicePlanId.isEmpty)
      return invalid("Service plan ID is required");

    auto plan = plans.findById(tenant, request.servicePlanId);
    if (plan.isNull)
      return notFound("Service plan");

    // The global account can be derived from the subaccount / directory.
    auto gaId = request.globalAccountId;
    if (!request.subaccountId.isEmpty) {
      auto sub = subaccounts.findById(tenant, request.subaccountId);
      if (sub.isNull)
        return notFound("Subaccount");
      if (!gaId.isEmpty && gaId != sub.globalAccountId)
        return violation("Subaccount belongs to another global account");
      if (!plan.availableIn(sub.region))
        return violation("Service plan '" ~ plan.planName ~ "' is not available in region " ~ sub.region);
      gaId = sub.globalAccountId;
    }
    if (!request.directoryId.isEmpty) {
      auto dir = directories.findById(tenant, request.directoryId);
      if (dir.isNull)
        return notFound("Directory");
      if (!gaId.isEmpty && gaId != dir.globalAccountId)
        return violation("Directory belongs to another global account");
      gaId = dir.globalAccountId;
    }
    if (gaId.isEmpty)
      return invalid("Global account ID is required");
    if (!globalAccounts.existsById(tenant, gaId))
      return notFound("Global account");

    auto validation = evaluator.validate(plan, repo.findByServicePlan(tenant, gaId, plan.id),
      request.quotaAssigned, request.unlimited);
    if (!validation.valid)
      return violation(validation.reason);

    auto entitlement = Entitlement(tenant);
    entitlement.globalAccountId = gaId;
    entitlement.directoryId = request.directoryId;
    entitlement.subaccountId = request.subaccountId;
    entitlement.servicePlanId = plan.id;
    entitlement.serviceName = plan.serviceName;
    entitlement.planName = plan.planName;
    entitlement.planDisplayName = plan.planDisplayName;
    entitlement.category = plan.category;
    entitlement.quotaAssigned = request.unlimited ? 0 : request.quotaAssigned;
    entitlement.quotaRemaining = entitlement.quotaAssigned;
    entitlement.unlimited = request.unlimited;
    entitlement.autoAssign = request.autoAssign;
    entitlement.status = EntitlementStatus.active;
    entitlement.assignedAt = entitlement.createdAt;
    entitlement.assignedBy = actor(request.assignedBy);
    entitlement.createdBy = entitlement.assignedBy;
    entitlement.updatedBy = entitlement.assignedBy;

    repo.save(entitlement);
    recorder.record(tenant, PlatformEventRecorder.ofEntitlement(entitlement),
      EnvironmentEventCategory.entitlementChange, "entitlement.assigned",
      "Entitlement assigned: " ~ plan.serviceName ~ "/" ~ plan.planName
      ~ (request.unlimited ? " (unlimited)" : " × " ~ request.quotaAssigned.to!string), entitlement.assignedBy);
    return created(entitlement.id.value, "Entitlement assigned");
  }

  UsecaseResult updateEntitlementQuota(UpdateEntitlementQuotaRequest request) {
    auto ent = repo.findById(request.tenantId, request.entitlementId);
    if (ent.isNull)
      return notFound("Entitlement");

    auto plan = plans.findById(request.tenantId, ent.servicePlanId);
    if (!plan.isNull) {
      auto validation = evaluator.validate(plan, repo.findByServicePlan(request.tenantId, ent.globalAccountId, plan.id),
        request.quotaAssigned, request.unlimited, ent.id);
      if (!validation.valid)
        return violation(validation.reason);
    }

    return guarded(() {
      auto before = ent.quotaAssigned;
      ent.reassign(request.unlimited ? 0 : request.quotaAssigned, request.unlimited, UserId("system"));
      repo.update(ent);
      recorder.record(request.tenantId, PlatformEventRecorder.ofEntitlement(ent),
        EnvironmentEventCategory.quotaChange, "entitlement.quotaChanged",
        "Quota of " ~ ent.serviceName ~ "/" ~ ent.planName ~ " changed", ent.updatedBy,
        ent.isOverQuota ? EnvironmentEventSeverity.warning : EnvironmentEventSeverity.info,
        ["from": before.to!string, "to": ent.quotaAssigned.to!string]);
      return ok(ent.id.value, "Quota updated");
    });
  }

  UsecaseResult revokeEntitlement(TenantId tenantId, EntitlementId id) {
    auto ent = repo.findById(tenantId, id);
    if (ent.isNull)
      return notFound("Entitlement");
    return guarded(() {
      ent.revoke(UserId("system"));
      repo.update(ent);
      recorder.record(tenantId, PlatformEventRecorder.ofEntitlement(ent),
        EnvironmentEventCategory.entitlementChange, "entitlement.revoked",
        "Entitlement revoked: " ~ ent.serviceName ~ "/" ~ ent.planName, ent.updatedBy, EnvironmentEventSeverity.warning);
      return ok(ent.id.value, "Entitlement revoked");
    });
  }

  Entitlement getEntitlement(TenantId tenantId, EntitlementId id) {
    return repo.findById(tenantId, id);
  }

  Entitlement[] listEntitlements(TenantId tenantId) {
    return repo.findByTenant(tenantId);
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

  UsecaseResult deleteEntitlement(TenantId tenantId, EntitlementId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return notFound("Entitlement");
    if (entity.quotaUsed > 0 && entity.consumesQuota)
      return violation("Entitlement is in use (" ~ entity.quotaUsed.to!string ~ " units); revoke it first");

    repo.remove(entity);
    recorder.record(tenantId, PlatformEventRecorder.ofEntitlement(entity),
      EnvironmentEventCategory.entitlementChange, "entitlement.deleted",
      "Entitlement deleted: " ~ entity.serviceName ~ "/" ~ entity.planName, UserId("system"));
    return ok(entity.id.value, "Entitlement deleted");
  }
}
