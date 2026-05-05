/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.tenant;

// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.tenant;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for tenant persistence.
class MemoryTenantRepository : TenantRepository {
  private Tenant[TenantId] store;

  bool existsById(TenantId id) {
    return (id in store) ? true : false;
  }

  Tenant findById(TenantId id) {
    if (existsById(id))
      return store[id];
    return Tenant.init;
  }

  Tenant findBySubdomain(string subdomain) {
    foreach (t; findAll()) {
      if (t.subdomain == subdomain)
        return t;
    }
    return Tenant.init;
  }

  Tenant[] findAll(size_t offset = 0, size_t limit = 100) {
    Tenant[] result;
    size_t idx;
    foreach (t; findAll()) {
      if (idx >= offset && result.length < limit)
        result ~= t;
      idx++;
    }
    return result;
  }

  void save(Tenant tenant) {
    store[tenant.id] = tenant;
  }

  void update(Tenant tenant) {
    store[tenant.id] = tenant;
  }

  void remove(TenantId id) {
    removeById(id);
  }
}
