/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.org;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.organization;
import uim.platform.foundry.domain.ports.repositories.org;

// import std.algorithm : filter;
// import std.array : array;

class MemoryOrgRepository : OrgRepository {
  private Organization[OrgId] store;

  Organization[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Organization* findById(OrgId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Organization* findByName(TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  void save(Organization org) {
    store[org.id] = org;
  }

  void update(Organization org) {
    store[org.id] = org;
  }

  void remove(OrgId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
