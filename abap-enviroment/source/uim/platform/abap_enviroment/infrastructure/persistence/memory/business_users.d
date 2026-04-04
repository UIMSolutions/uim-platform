/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_enviroment.infrastructure.persistence.memory.business_user_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.business_user;
// import uim.platform.abap_enviroment.domain.ports.business_user_repository;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:

class MemoryBusinessUserRepository : BusinessUserRepository {
  private BusinessUser[BusinessUserId] store;

  BusinessUser* findById(BusinessUserId id) {
    if (auto p = id in store)
      return p;
    return null;
  }

  BusinessUser[] findBySystem(SystemInstanceId systemId) {
    return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
  }

  BusinessUser[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  BusinessUser* findByUsername(SystemInstanceId systemId, string username) {
    foreach (ref e; store.byValue())
      if (e.systemInstanceId == systemId && e.username == username)
        return &store[e.id];
    return null;
  }

  BusinessUser* findByEmail(SystemInstanceId systemId, string email) {
    foreach (ref e; store.byValue())
      if (e.systemInstanceId == systemId && e.email == email)
        return &store[e.id];
    return null;
  }

  void save(BusinessUser user) {
    store[user.id] = user;
  }

  void update(BusinessUser user) {
    store[user.id] = user;
  }

  void remove(BusinessUserId id) {
    store.remove(id);
  }
}
