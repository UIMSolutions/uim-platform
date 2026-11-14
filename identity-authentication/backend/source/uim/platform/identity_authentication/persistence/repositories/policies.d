/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.policies;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class PolicyRepository : TenantRepository!(AuthorizationPolicy, PolicyId), IPolicyRepository {
  mixin TenantRepositoryTemplate!(PolicyRepository, AuthorizationPolicy, PolicyId);

  size_t countByApplication(TenantId tenantId, ApplicationId appId) {
    return findByApplication(tenantId, appId).length;
  }

  AuthorizationPolicy[] findByApplication(TenantId tenantId, ApplicationId appId) {
    return findByTenant(tenantId).filter!(p => p.appliesTo(appId)).array;
  }

  void removeByApplication(TenantId tenantId, ApplicationId appId) {
    remove(findByTenant(tenantId).filter!(p => p.applicationIds.canFind(appId.value)).array);
  }
}
///
unittest {
  assert(tenantRepositoryTest(new PolicyRepository()));
}
