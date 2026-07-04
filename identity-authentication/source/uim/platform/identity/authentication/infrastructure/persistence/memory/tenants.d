/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.tenants;
// import uim.platform.identity.authentication.domain.entities.tenant;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.tenant;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for tenant persistence.
class MemoryTenantRepository : IdMTenantRepository {
  private IdMTenant[IdMTenantId] store;

  bool existsById(IdMTenantId id) {
    return (id in store) ? true : false;
  }

  IdMTenant findById(IdMTenantId id) {
    if (existsById(id))
      return store[id];
    return IdMTenant.init;
  }

  IdMTenant findBySubdomain(string subdomain) {
    foreach (t; store.byValue) {
      if (t.subdomain == subdomain)
        return t;
    }
    return IdMTenant.init;
  }

  IdMTenant[] findAll(size_t offset = 0, size_t limit = 100) {
    IdMTenant[] result;
    size_t idx;
    foreach (t; store.byValue) {
      if (idx >= offset && result.length < limit)
        result ~= t;
      idx++;
    }
    return result;
  }

  void save(IdMTenant tenant) {
    store[tenant.id] = tenant;
  }

  void update(IdMTenant tenant) {
    store[tenant.id] = tenant;
  }

  void remove(IdMTenant tenant) {
    store.remove(tenant.id);
  }
}
