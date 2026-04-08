/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.group;

// import uim.platform.identity_authentication.domain.entities.group;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.group;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for group persistence.
class MemoryGroupRepository : GroupRepository {
  private IdaGroup[GroupId] store;

  IdaGroup findById(GroupId id) {
    if (auto p = id in store)
      return *p;
    return IdaGroup.init;
  }

  IdaGroup[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    IdaGroup[] result;
    uint idx;
    foreach (g; store.byValue()) {
      if (g.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= g;
        idx++;
      }
    }
    return result;
  }

  void save(IdaGroup group) {
    store[group.id] = group;
  }

  void update(IdaGroup group) {
    store[group.id] = group;
  }

  void remove(GroupId id) {
    store.remove(id);
  }
}
