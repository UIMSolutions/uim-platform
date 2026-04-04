/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.policy_repo;

// import uim.platform.identity_authentication.domain.entities.policy;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.policy;
// 
// // import std.algorithm : canFind;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for authorization policy persistence.
class MemoryPolicyRepository : PolicyRepository
{
  private AuthorizationPolicy[PolicyId] store;

  bool existsById(PolicyId id)
  {
    return (id in store) ? true : false;
  }

  AuthorizationPolicy findById(PolicyId id)
  {
    if (id in store)
      return store[id];
    return AuthorizationPolicy.init;
  }

  AuthorizationPolicy[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(p => p.tenantId == tenantId).array;
  }

  AuthorizationPolicy[] findByApplication(ApplicationId appId)
  {
    return store.byValue().filter!(p => p.applicationIds.canFind(appId)).array;
  }

  void save(AuthorizationPolicy policy)
  {
    store[policy.id] = policy;
  }

  void update(AuthorizationPolicy policy)
  {
    store[policy.id] = policy;
  }

  void remove(PolicyId id)
  {
    store.remove(id);
  }
}
