/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.roles;

// import uim.platform.portal.domain.entities.role;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.roles;

// import std.algorithm : canFind;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryRoleRepository : RoleRepository {
  private Role[RoleId] store;

  bool existsById(RoleId id) {
    return id in store ? true : false;
  }

  Role findById(RoleId id) {
    return existsById(id) ? store[id] : Role.init;
  }

  bool existsByName(TenantId tenantId, string name) {
    return store.byValue().any!(r => r.tenantId == tenantId && r.name == name);
  }

  Role findByName(TenantId tenantId, string name) {
    foreach (r; store.byValue()) {
      if (r.tenantId == tenantId && r.name == name)
        return r;
    }
    return Role.init;
  }

  Role[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100) {
    Role[] result;
    uint idx;
    foreach (r; store.byValue()) {
      if (r.tenantId == tenantId) {
        if (idx >= offset && result.length < limit)
          result ~= r;
        idx++;
      }
    }
    return result;
  }

  Role[] findByUser(string userId) {
    Role[] result;
    foreach (r; store.byValue()) {
      if (r.userIds.canFind(userId))
        result ~= r;
    }
    return result;
  }

  void save(Role role) {
    store[role.id] = role;
  }

  void update(Role role) {
    store[role.id] = role;
  }

  void remove(RoleId id) {
    store.remove(id);
  }
}
