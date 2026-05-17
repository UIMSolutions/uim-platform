/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.idp_config;
// import uim.platform.identity.authentication.domain.entities.idp_config;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.idp_config;
// import std.algorithm : canFind;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for external IdP configuration persistence.
class MemoryIdpConfigRepository : TenantRepository!(IdpConfig, string), IdpConfigRepository {

  bool exists(string id) {
    return findByTenant(tenantId).any!(c => c.id == id);
  }
  IdpConfig findDefaultForTenant(TenantId tenantId) {
    foreach (c; findByTenant(tenantId)) {
      if (c.tenantId == tenantId && c.isDefault)
        return c;
    }
    return IdpConfig.init;
  }

  bool hasDomainHint(TenantId tenantId, string emailDomain) {
    foreach (c; findByTenant(tenantId)) {
      if (c.tenantId == tenantId && c.domainHints.canFind(emailDomain))
        return true;
    }
    return false;
  }
  IdpConfig findByDomainHint(TenantId tenantId, string emailDomain) {
    foreach (c; findByTenant(tenantId)) {
      if (c.tenantId == tenantId && c.domainHints.canFind(emailDomain))
        return c;
    }
    return IdpConfig.init;
  }

}
