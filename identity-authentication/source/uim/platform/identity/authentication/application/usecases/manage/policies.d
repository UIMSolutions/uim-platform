/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.application.usecases.manage.policies;
// import uim.platform.identity.authentication.domain.entities.policy;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.policy;
// import uim.platform.identity.authentication.application.dto;
// 
// 
// 
import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// Application use case: authorization policy management.
class ManagePoliciesUseCase { // TODO: UIMUseCase {
  private PolicyRepository policyRepo;

  this(PolicyRepository policyRepo) {
    this.policyRepo = policyRepo;
  }

  PolicyResponse createPolicy(CreatePolicyRequest req) {
    auto now = currentTimestamp();
    auto policy = AuthorizationPolicy(randomUUID().toString(), req.tenantId,
      req.name, req.description, req.rules, req.applicationIds, true, now, now);
    policyRepo.save(policy);
    return PolicyResponse(policy.id.value, "");
  }

  AuthorizationPolicy getPolicy(TenantId tenantId, PolicyId id) {
    return policyRepo.findById(tenantId, id);
  }

  AuthorizationPolicy[] listPolicies(TenantId tenantId) {
    return policyRepo.findByTenant(tenantId);
  }

  CommandResult deletePolicy(TenantId tenantId, PolicyId id) {
    auto policy = policyRepo.findById(tenantId, id);
    if (policy.isNull)
      return CommandResult(false, "", "Policy not found.");

    policyRepo.remove(policy);
    return CommandResult(true, policy.id.value, "Policy deleted successfully.");
  }
}
