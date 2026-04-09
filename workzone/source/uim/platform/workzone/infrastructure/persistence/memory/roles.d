/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.roles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.role;
import uim.platform.workzone.domain.ports.repositories.roles;

// import std.algorithm : filter;
// import std.array : array;

class MemoryRoleRepository : RoleRepository {
  private Role[RoleId] store;

  Role[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  Role* findById(RoleId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Role[] findByUser(UserId usertenantId, id tenantId) {
    Role[] result;
    foreach (ref r; store.byValue()) {
      if (r.tenantId != tenantId)
        continue;
      foreach (ref uid; r.assignedUserIds)
        if (uid == userId)
        {
          result ~= r;
          break;
        }
    }
    return result;
  }

  void save(Role role) {
    store[role.id] = role;
  }

  void update(Role role) {
    store[role.id] = role;
  }

  void remove(RoleId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
