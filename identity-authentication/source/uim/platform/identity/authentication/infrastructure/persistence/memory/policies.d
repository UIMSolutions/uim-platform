/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.policies;
// import uim.platform.identity.authentication.domain.entities.policy;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.policy;
// 
// import std.algorithm : canFind;

import uim.platform.identity.authentication;

// mixin(ShowModule!());
@safe:
/// In-memory adapter for authorization policy persistence.
class MemoryPolicyRepository : TenantRepository!(AuthorizationPolicy, PolicyId), PolicyRepository {

  size_t countByApplication(TenantId tenantId, ApplicationId appId) {
    return findByApplication(tenantId, appId).length;
  }

  AuthorizationPolicy[] filterByApplication(AuthorizationPolicy[] policies, ApplicationId appId) {
    return policies.filter!(p => p.applicationIds.canFind(appId)).array;
  }

  AuthorizationPolicy[] findByApplication(TenantId tenantId, ApplicationId appId) {
    return filterByApplication(find(tenantId), appId);
  }

  void removeByApplication(TenantId tenantId, ApplicationId appId) {
    findByApplication(tenantId, appId).each!(policy => remove(policy));
  }

}
