/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.policies;

// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.policy;
// import uim.platform.identity_authentication.application.dto;
// 
// // import std.uuid;
// // import std.datetime.systime : Clock;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: authorization policy management.
class ManagePoliciesUseCase
{
  private PolicyRepository policyRepo;

  this(PolicyRepository policyRepo)
  {
    this.policyRepo = policyRepo;
  }

  PolicyResponse createPolicy(CreatePolicyRequest req)
  {
    auto now = Clock.currStdTime();
    auto policy = AuthorizationPolicy(randomUUID().toString(), req.tenantId,
        req.name, req.description, req.rules, req.applicationIds, true, now, now);
    policyRepo.save(policy);
    return PolicyResponse(policy.id, "");
  }

  AuthorizationPolicy getPolicy(PolicyId id)
  {
    return policyRepo.findById(id);
  }

  AuthorizationPolicy[] listPolicies(TenantId tenantId)
  {
    return policyRepo.findByTenant(tenantId);
  }

  string deletePolicy(PolicyId id)
  {
    policyRepo.remove(id);
    return "";
  }
}
