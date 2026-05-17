/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.identity_providers;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryIdentityProviderRepository : IdentityProviderRepository {
  private IdentityProviderEntity[IdentityProviderId] store;

  bool existsById(IdentityProviderId id) {
    return (id in store) !is null;
  }

  IdentityProviderEntity findById(IdentityProviderId id) {
    return existsById(id) ? store[id] : IdentityProviderEntity.init;
  }

  bool existsByAlias(string alias_) {
    return findByAlias(alias_).id.length > 0;
  }

  IdentityProviderEntity findByAlias(string alias_) {
    foreach (idp; store.values)
      if (idp.alias_ == alias_)
        return idp;
    return IdentityProviderEntity.init;
  }

  IdentityProviderEntity[] findByTenant(tenantId) {
    return store.values.dup;
  }

  IdentityProviderEntity findDefault() {
    foreach (idp; store.values)
      if (idp.isDefault)
        return idp;
    return IdentityProviderEntity.init;
  }

  void save(IdentityProviderEntity idp) {
    store[idp.id] = idp;
  }

  void update(IdentityProviderEntity idp) {
    store[idp.id] = idp;
  }

  void remove(IdentityProviderId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
