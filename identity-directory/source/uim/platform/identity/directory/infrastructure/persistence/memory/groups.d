/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.groups;

import uim.platform.identity.directory.domain.entities.group;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.repositories.groups;

/// In-memory adapter for group persistence.
class MemoryGroupRepository : GroupRepository {
  private Group[GroupId] store;

  Group findById(GroupId id) {
    if (auto p = id in store)
      return *p;
    return Group.init;
  }

  Group findByDisplayName(TenantId tenantId, string displayName) {
    foreach (g; store.byValue())
    {
      if (g.tenantId == tenantId && g.displayName == displayName)
        return g;
    }
    return Group.init;
  }

  Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Group[] result;
    uint idx;
    foreach (g; store.byValue())
    {
      if (g.tenantId == tenantId)
      {
        if (idx >= offset && result.length < limit)
          result ~= g;
        idx++;
      }
    }
    return result;
  }

  Group[] findByMember(string memberId) {
    Group[] result;
    foreach (g; store.byValue())
    {
      if (g.hasMember(memberId))
        result ~= g;
    }
    return result;
  }

  void save(Group group) {
    store[group.id] = group;
  }

  void update(Group group) {
    store[group.id] = group;
  }

  void remove(GroupId id) {
    store.remove(id);
  }

  ulong countByTenant(TenantId tenantId) {
    ulong count;
    foreach (g; store.byValue())
    {
      if (g.tenantId == tenantId)
        count++;
    }
    return count;
  }
}
