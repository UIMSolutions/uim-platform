/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.identity_providers;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class MemoryIdentityProviderRepository : TentRepository!(IdentityProvider, IdentityProviderId), IdentityProviderRepository {

  bool existsByAlias(TenantId tenantId, string alias_) {
    return findByTenant(tenantId).any!(idp => idp.alias_ == alias_);
  }

  IdentityProvider findByAlias(TenantId tenantId, string alias_) {
    foreach (idp; findByTenant(tenantId))
      if (idp.alias_ == alias_)
        return idp;
    return IdentityProvider.init;
  }
  void removeByAlias(TenantId tenantId, string alias_) {
    remove(findByAlias(tenantId, alias_));
  }

  bool existsDefault(TenantId tenantId) {
    foreach (idp; findByTenant(tenantId))
      if (idp.isDefault)
        return true;
    return false;
  }
  IdentityProvider findDefault(TenantId tenantId) {
    foreach (idp; findByTenant(tenantId))
      if (idp.isDefault)
        return idp;
    return IdentityProvider.init;
  }
  void removeDefault(TenantId tenantId) {
    remove(findDefault(tenantId));
  }
}
