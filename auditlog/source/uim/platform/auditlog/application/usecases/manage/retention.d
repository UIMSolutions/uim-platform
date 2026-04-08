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

class ManageRetentionUseCase : UIMUseCase {
  private RetentionPolicyRepository policyRepo;

  this(RetentionPolicyRepository policyRepo) {
    this.policyRepo = policyRepo;
  }

  CommandResult createPolicy(CreateRetentionPolicyRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Policy name is required");
    if (req.retentionDays <= 0)
      return CommandResult("", "Retention days must be positive");

    auto now = Clock.currStdTime();
    auto policy = RetentionPolicy();
    policy.id = randomUUID();
    policy.tenantId = req.tenantId;
    policy.name = req.name;
    policy.description = req.description;
    policy.retentionDays = req.retentionDays;
    policy.categories = req.categories;
    policy.isDefault = req.isDefault;
    policy.status = RetentionStatus.active;
    policy.createdAt = now;
    policy.updatedAt = now;

    policyRepo.save(policy);
    return CommandResult(policy.id.toString, "");
  }

  bool existsPolicy(RetentionPolicyId id, TenantId tenantId) {
    return policyRepo.existsById(id, tenantId);
  }

  RetentionPolicy getPolicy(RetentionPolicyId id, TenantId tenantId) {
    return policyRepo.findById(id, tenantId);
  }

  RetentionPolicy[] listPolicies(TenantId tenantId) {
    return policyRepo.findByTenant(tenantId);
  }

  CommandResult updatePolicy(UpdateRetentionPolicyRequest req) {
    if (!policyRepo.existsById(req.id, req.tenantId))
      return CommandResult("", "Retention policy not found");

    auto policy = policyRepo.findById(req.id, req.tenantId);
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
    return CommandResult(policy.id.toString, "");
  }

  void deletePolicy(RetentionPolicyId id, TenantId tenantId) {
    policyRepo.remove(id, tenantId);
  }
}
