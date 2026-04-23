/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.roles;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.role;
// import uim.platform.workzone.domain.ports.repositories.roles;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class MemoryRoleRepository : TenantRRepository!(Role, RoleId), RoleRepository {

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  Role[] findByUser(TenantId tenantId, UserId userId) {
    Role[] result;
    foreach (r; findByTenant(tenantId)) {
      foreach (uid; r.assignedUserIds)
        if (uid == userId) {
          result ~= r;
          break;
        }
    }
    return result;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(r => remove(r));
  }

}
