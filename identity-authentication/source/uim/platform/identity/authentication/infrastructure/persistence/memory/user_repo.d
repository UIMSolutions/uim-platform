/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.user;

// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.user;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for user persistence (swap for DB adapter in production).
class MemoryUserRepository : TenantRepository!(User, UserId), UserRepository {

  bool existsByEmail(TenantId tenantId, string email) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.email == email)
        return true;
    }
    return false;
  }
  User findByEmail(TenantId tenantId, string email) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.email == email)
        return u;
    }
    return User.init;
  }

  bool existsByUserName(TenantId tenantId, string userName) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.userName == userName)
        return true;
    }
    return false;
  }
  User findByUserName(TenantId tenantId, string userName) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.userName == userName)
        return u;
    }
    return User.init;
  }


  size_t countByGroupId(GroupId groupId) {
    return findByGroupId(groupId).length;
  }
  User[] filterByGroupId(User[] users, GroupId groupId) {
    return users.filter!(u => u.groupIds.canFind(groupId)).array;
  }
  User[] findByGroupId(GroupId groupId) {
    return findAll().filter!(u => u.groupIds.canFind(groupId)).array;
  }
  void removeByGroupId(GroupId groupId) {
    findByGroupId(groupId).each!(u => remove(u.id));
  }

}
