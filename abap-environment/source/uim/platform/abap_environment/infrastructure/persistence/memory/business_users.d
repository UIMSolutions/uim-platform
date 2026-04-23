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

  BusinessUser findByUsername(SystemInstanceId systemId, string username) {
    foreach (e; findBySystem(systemId))
      if (e.username == username)
        return store[e.id];
    return BusinessUser.init;
  }

  BusinessUser findByEmail(SystemInstanceId systemId, string email) {
    foreach (e; findBySystem(systemId))
      if (e.email == email)
        return store[e.id];
    return BusinessUser.init;
  }

  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  BusinessUser[] findBySystem(SystemInstanceId systemId) {
    return findAll.filter!(e => e.systemInstanceId == systemId).array;
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }

}
