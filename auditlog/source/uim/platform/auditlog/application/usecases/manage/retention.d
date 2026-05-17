/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.retention;


// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;
// import uim.platform.auditlog.domain.ports.repositories.retention_policys;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

class ManageRetentionUseCase { // TODO: UIMUseCase {
  private RetentionPolicyRepository repo;

  this(RetentionPolicyRepository repo) {
    this.repo = repo;
  }

  CommandResult createPolicy(CreateRetentionPolicyRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Policy name is required");
    if (req.retentionDays <= 0)
      return CommandResult(false, "", "Retention days must be positive");

    auto now = currentTimestamp();
    RetentionPolicy policy;
    policy.initEntity(req.tenantId);
    with (policy) {
      name = req.name;
      description = req.description;
      retentionDays = req.retentionDays;
      categories = req.categories;
      isDefault = req.isDefault;
      status = RetentionStatus.active;
    }

    repo.save(policy);
    return CommandResult(true, policy.id.value, "");
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

  CommandResult updatePolicy(UpdateRetentionPolicyRequest req) {
    auto policy = repo.findById(req.tenantId, req.retentionPolicyId);
    if (policy.isNull)
      return CommandResult(false, "", "Retention policy not found");

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
    return CommandResult(true, policy.id.value, "");
  }

  CommandResult deletePolicy(TenantId tenantId, RetentionPolicyId policyId) {
    auto policy = repo.findById(tenantId, policyId);
    if (policy.isNull)
      return CommandResult(false, "", "Retention policy not found");

    repo.remove(policy);
    return CommandResult(true, policy.id.value, "");
  }
}
