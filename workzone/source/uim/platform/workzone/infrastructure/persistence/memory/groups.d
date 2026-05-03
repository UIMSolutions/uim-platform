/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.groups;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.group;
// import uim.platform.workzone.domain.ports.repositories.groups;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryGroupRepository : TenantRepository!(WZGroup, GroupId), GroupRepository {

  size_t countByMember(TenantId tenantId, UserId userId) {
    return findByMember(tenantId, userId).length;
  }

  WZGroup[] findByMember(TenantId tenantId, UserId userId) {
    WZGroup[] result;
    foreach (g; findByTenant(tenantId)) {
      foreach (mid; g.memberIds)
        if (mid == userId) {
          result ~= g;
          break;
        }
    }
    return result;
  }

  void removeByMember(TenantId tenantId, UserId userId) {
    findByMember(tenantId, userId).each!(g => remove(g));
  }

}
