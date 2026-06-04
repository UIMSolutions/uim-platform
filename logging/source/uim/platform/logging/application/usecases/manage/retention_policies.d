/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.retention_policies;
// import uim.platform.logging.domain.entities.retention_policy;
// import uim.platform.logging.domain.ports.repositories.retention_policys;
// import uim.platform.logging.domain.services.retention_evaluator;

// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageRetentionPoliciesUseCase { // TODO: UIMUseCase {
  private RetentionPolicyRepository repo;

  this(RetentionPolicyRepository repo) {
    this.repo = repo;
  }

  CommandResult createRetentionPolicy(CreateRetentionPolicyRequest req) {
    import std.uuid : randomUUID;

    RetentionPolicy p;
    p.initEntity(req.tenantId, req.createdBy);

    p.name = req.name;
    p.description = req.description;
    p.dataType = req.dataType.to!DataType;
    p.retentionDays = (req.retentionDays > 0) ? req.retentionDays : 30;
    p.maxSizeGB = (req.maxSizeGB > 0) ? req.maxSizeGB : 10.0;
    p.isDefault = req.isDefault;
    p.isActive = true;

    auto validation = RetentionEvaluator.validate(p);
    if (!validation.valid) {
      string msg;
      foreach (e; validation.errors)
        msg ~= e ~ "; ";
      return CommandResult(false, "", msg);
    }

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult updateRetentionPolicy(UpdateRetentionPolicyRequest req) {
    auto policy = repo.findById(req.tenantId, req.policyId);
    if (policy.isNull)
      return CommandResult(false, "", "Retention policy not found");

    if (req.description.length > 0)
      policy.description = req.description;
    if (req.retentionDays > 0)
      policy.retentionDays = req.retentionDays;
    if (req.maxSizeGB > 0)
      policy.maxSizeGB = req.maxSizeGB;
    policy.isDefault = req.isDefault;
    policy.isActive = req.isActive;
    policy.updatedAt = clockSeconds();

    repo.update(policy);
    return CommandResult(true, policy.id.value, "");
  }

  RetentionPolicy getRetentionPolicy(TenantId tenantId, RetentionPolicyId id) {
    return repo.findById(tenantId, id);
  }

  RetentionPolicy[] listRetentionPolicies(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteRetentionPolicy(TenantId tenantId, RetentionPolicyId policyId) {
    auto policy = repo.findById(tenantId, policyId);
    if (policy.isNull)
      return CommandResult(false, "", "Retention policy not found");

    repo.remove(policy);
    return CommandResult(true, policy.id.value, "");
  }

}
