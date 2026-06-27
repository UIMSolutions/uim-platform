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

// mixin(ShowModule!());

@safe:
class MemoryRoleRepository : TentRepository!(Role, RoleId), RoleRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(r => r.name == name);
  }

  Role findByName(TenantId tenantId, string name) {
    foreach (r; findByTenant(tenantId))
      if (r.name == name)
        return r;
    return Role.init;
  }

  void removeByName(TenantId tenantId, string name) {
    foreach (r; findByTenant(tenantId))
      if (r.name == name) {
        store.remove(r.id);
        return;
      }
  }

  size_t countByUser(UserId userId) {
    return findByUser(userId).length;
  }

  Role[] findByUser(UserId userId) {
    Role[] result;
    foreach (r; findByTenant(tenantId))
      if (r.userIds.canFind(userId))
        result ~= r;
    return result;
  }

  void removeByUser(UserId userId) {
    foreach (r; findByTenant(tenantId))
      if (r.userIds.canFind(userId))
        store.remove(r.id);
  }

}
