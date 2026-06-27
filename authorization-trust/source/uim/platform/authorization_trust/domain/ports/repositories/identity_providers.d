/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.identity_providers;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

interface IdentityProviderRepository : ITentRepository!(IdentityProvider, IdentityProviderId) {

  bool existsByAlias(TenantId tenantId, string alias_);
  IdentityProvider findByAlias(TenantId tenantId, string alias_);
  void removeByAlias(TenantId tenantId, string alias_);

  bool existsDefault(TenantId tenantId);
  IdentityProvider findDefault(TenantId tenantId);
  void removeDefault(TenantId tenantId);

}
