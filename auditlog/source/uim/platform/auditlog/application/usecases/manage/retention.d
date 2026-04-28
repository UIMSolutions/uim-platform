/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.application.usecases.manage.retention;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;
// import uim.platform.auditlog.domain.ports.repositories.retention_policys;
// import uim.platform.auditlog.application.dto;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

class ManageRetentionUseCase { // TODO: UIMUseCase {
  private RetentionPolicyRepository policyRepo;

  this(RetentionPolicyRepository policyRepo) {
    this.policyRepo = policyRepo;
  }

  CommandResult createPolicy(CreateRetentionPolicyRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Policy name is required");
    if (req.retentionDays <= 0)
      return CommandResult(false, "", "Retention days must be positive");

    auto now = Clock.currStdTime();
    auto policy = RetentionPolicy();
    with (policy) {
      tenantId = req.tenantId;
      id = randomUUID();
      name = req.name;
      description = req.description;
      retentionDays = req.retentionDays;
      categories = req.categories;
      isDefault = req.isDefault;
      status = RetentionStatus.active;
      createdAt = now;
      updatedAt = now;
    }

    policyRepo.save(policy);
    return CommandResult(true, policy.id.toString(), "");
  }

  bool existsPolicy(TenantId tenantId, RetentionPolicyId policyId) {
    return policyRepo.existsById(tenantId, policyId);
  }

  RetentionPolicy getPolicy(TenantId tenantId, RetentionPolicyId policyId) {
    return policyRepo.findById(tenantId, policyId);
  }

  RetentionPolicy[] listPolicies(TenantId tenantId) {
    return policyRepo.findByTenant(tenantId);
  }

  CommandResult updatePolicy(UpdateRetentionPolicyRequest req) {
    auto policy = policyRepo.findById(req.tenantId, req.id);
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
    policy.updatedAt = Clock.currStdTime();

    policyRepo.update(policy);
    return CommandResult(true, policy.id.toString(), "");
  }

  void deletePolicy(TenantId tenantId, RetentionPolicyId policyId) {
    policyRepo.removeById(tenantId, policyId);
  }
}
