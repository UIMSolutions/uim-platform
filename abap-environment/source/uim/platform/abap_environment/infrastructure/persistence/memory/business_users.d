/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.business_users;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.ports.repositories.business_users;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryBusinessUserRepository : TenantRepository!(BusinessUser, BusinessUserId), BusinessUserRepository {

  bool existsByUsername(SystemInstanceId systemId, string username) {
    return findBySystem(systemId).any!(e => e.username == username);
  }

  BusinessUser findByUsername(SystemInstanceId systemId, string username) {
    foreach (e; findBySystem(systemId))
      if (e.username == username)
        return e;
    return BusinessUser.init;
  }

  void removeByUsername(SystemInstanceId systemId, string username) {
    findByUsername(systemId, username).remove();
  }

  bool existsByEmail(SystemInstanceId systemId, string email) {
    return findBySystem(systemId).any!(e => e.email == email);
  }

  BusinessUser findByEmail(SystemInstanceId systemId, string email) {
    foreach (e; findBySystem(systemId))
      if (e.email == email)
        return e;
    return BusinessUser.init;
  }

  void removeByEmail(SystemInstanceId systemId, string email) {
    findByEmail(systemId, email).remove();
  }

  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  BusinessUser[] filterBySystem(BusinessUser[] users, SystemInstanceId systemId) {
    return users.filter!(e => e.systemInstanceId == systemId).array;
  }

  BusinessUser[] findBySystem(SystemInstanceId systemId) {
    return findAll().filterBySystem(systemId);
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }

}
