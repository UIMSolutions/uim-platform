/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.retention;



// import uim.platform.auditlog.domain.entities.retention_policy;
// import uim.platform.auditlog.ports.repositories.retention_policys;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Interactor: CRUD for retention policies. Only one active default policy per tenant.
class ManageRetentionUseCase : IManageRetentionUseCase {
  protected IRetentionPolicyRepository repo;

  this(IRetentionPolicyRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createPolicy(CreateRetentionPolicyRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Policy name is required");
    if (req.retentionDays <= 0)
      return UsecaseResult(false, "", "Retention days must be positive");

    if (req.isDefault)
      clearDefault(req.tenantId);

    auto policy = RetentionPolicy(req.tenantId);
    with (policy) {
      name = req.name;
      description = req.description;
      retentionDays = req.retentionDays;
      categories = req.categories;
      isDefault = req.isDefault;
      status = RetentionStatus.active;
    }

    repo.save(policy);
    return UsecaseResult(true, policy.id.value, "");
  }

  bool existsPolicy(TenantId tenantId, RetentionPolicyId policyId) {
    return repo.existsById(tenantId, policyId);
  }

  RetentionPolicy getPolicy(TenantId tenantId, RetentionPolicyId policyId) {
    return repo.findById(tenantId, policyId);
  }

  RetentionPolicy[] listPolicies(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updatePolicy(UpdateRetentionPolicyRequest req) {
    auto policy = repo.findById(req.tenantId, req.retentionPolicyId);
    if (policy.isNull)
      return UsecaseResult(false, "", "Retention policy not found");

    if (req.name.length > 0)
      policy.name = req.name;
    if (req.description.length > 0)
      policy.description = req.description;
    if (req.retentionDays > 0)
      policy.retentionDays = req.retentionDays;
    if (req.categories.length > 0)
      policy.categories = req.categories;
    policy.status = req.status;
    policy.updatedAt = currentTimestamp();

    repo.update(policy);
    return UsecaseResult(true, policy.id.value, "");
  }

  /// Make sure at most one policy is flagged as default.
  protected void clearDefault(TenantId tenantId) {
    foreach (p; repo.findByTenant(tenantId)) {
      if (p.isDefault) {
        p.isDefault = false;
        repo.update(p);
      }
    }
  }

  UsecaseResult deletePolicy(TenantId tenantId, RetentionPolicyId policyId) {
    auto policy = repo.findById(tenantId, policyId);
    if (policy.isNull)
      return UsecaseResult(false, "", "Retention policy not found");

    repo.remove(policy);
    return UsecaseResult(true, policy.id.value, "");
  }
}

///
unittest {
  mixin(ShowTest!("ManageRetentionUseCase"));

  auto uc = new ManageRetentionUseCase(new RetentionPolicyRepository());
  auto tenant = TenantId("t1");

  CreateRetentionPolicyRequest req;
  req.tenantId = tenant;
  req.name = "short";
  req.retentionDays = 0;
  assert(uc.createPolicy(req).hasError);

  req.retentionDays = 30;
  req.isDefault = true;
  auto first = uc.createPolicy(req);
  assert(first.isSuccess);
  req.name = "long";
  req.retentionDays = 365;
  auto second = uc.createPolicy(req);
  assert(second.isSuccess);

  // the newer default replaced the older one
  assert(!uc.getPolicy(tenant, RetentionPolicyId(first.id)).isDefault);
  assert(uc.getPolicy(tenant, RetentionPolicyId(second.id)).isDefault);
  assert(uc.listPolicies(tenant).length == 2);
  assert(uc.deletePolicy(tenant, RetentionPolicyId(first.id)).isSuccess);
  assert(uc.listPolicies(tenant).length == 1);
}
