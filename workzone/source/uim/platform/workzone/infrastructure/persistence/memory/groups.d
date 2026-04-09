/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.groups;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.group;
import uim.platform.workzone.domain.ports.repositories.groups;

// import std.algorithm : filter;
// import std.array : array;

class MemoryGroupRepository : GroupRepository {
  private Group[GroupId] store;

  Group[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(g => g.tenantId == tenantId).array;
  }

  Group* findById(GroupId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Group[] findByMember(UserId usertenantId, id tenantId) {
    Group[] result;
    foreach (ref g; store.byValue()) {
      if (g.tenantId != tenantId)
        continue;
      foreach (ref mid; g.memberIds)
        if (mid == userId)
        {
          result ~= g;
          break;
        }
    }
    return result;
  }

  void save(Group group) {
    store[group.id] = group;
  }

  void update(Group group) {
    store[group.id] = group;
  }

  void remove(GroupId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
