/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.users;
// import uim.platform.identity.authentication.domain.entities.user;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.user;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for user persistence (swap for DB adapter in production).
class MemoryUserRepository : TenantRepository!(IAUser, UserId), UserRepository {

  bool existsByEmail(TenantId tenantId, string email) {
    foreach (u; findByTenant(tenantId)) {
      if (u.tenantId == tenantId && u.email == email)
        return true;
    }
    return false;
  }
  IAUser findByEmail(TenantId tenantId, string email) {
    foreach (u; findByTenant(tenantId)) {
      if (u.tenantId == tenantId && u.email == email)
        return u;
    }
    return IAUser.init;
  }

  bool existsByUserName(TenantId tenantId, string userName) {
    foreach (u; findByTenant(tenantId)) {
      if (u.tenantId == tenantId && u.userName == userName)
        return true;
    }
    return false;
  }
  IAUser findByUserName(TenantId tenantId, string userName) {
    foreach (u; findByTenant(tenantId)) {
      if (u.tenantId == tenantId && u.userName == userName)
        return u;
    }
    return IAUser.init;
  }


  size_t countByGroupId(GroupId groupId) {
    return findByGroupId(groupId).length;
  }
  IAUser[] filterByGroupId(IAUser[] users, GroupId groupId) {
    return users.filter!(u => u.groupIds.canFind(groupId)).array;
  }
  IAUser[] findByGroupId(GroupId groupId) {
    return findByTenant(tenantId).filter!(u => u.groupIds.canFind(groupId)).array;
  }
  void removeByGroupId(GroupId groupId) {
    findByGroupId(groupId).each!(u => remove(u.id));
  }

}
