/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.repositories.identity_providers;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

interface IdentityProviderRepository {
  bool                   existsById(IdentityProviderId id);
  IdentityProviderEntity findById(IdentityProviderId id);

  bool                   existsByAlias(string alias_);
  IdentityProviderEntity findByAlias(string alias_);

  IdentityProviderEntity[] findAll();
  IdentityProviderEntity   findDefault();

  void save(IdentityProviderEntity idp);
  void update(IdentityProviderEntity idp);
  void remove(IdentityProviderId id);

  size_t count();
}
