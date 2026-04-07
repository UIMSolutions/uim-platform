/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.space;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.space;
import uim.platform.foundry.domain.ports.repositories.space;

// import std.algorithm : filter;
// import std.array : array;

class MemorySpaceRepository : SpaceRepository {
  private Space[SpaceId] store;

  Space[] findByOrg(OrgId orgId, TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.orgId == orgId).array;
  }

  Space* findById(SpaceId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Space* findByName(OrgId orgId, TenantId tenantId, string name) {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.orgId == orgId && e.name == name)
        return &e;
    return null;
  }

  Space[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void removeByOrg(OrgId orgId, TenantId tenantId) {
    SpaceId[] toRemove;
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.orgId == orgId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  void save(Space space) {
    store[space.id] = space;
  }

  void update(Space space) {
    store[space.id] = space;
  }

  void remove(SpaceId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
