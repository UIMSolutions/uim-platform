/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.repositories.business_users;

// import uim.platform.abap_environment.domain.entities.business_user;
// import uim.platform.abap_environment.domain.ports.repositories.business_users;

import uim.platform.abap_environment;

// mixin(ShowModule!());
@safe:

class MemoryBusinessUserRepository : TenantRepository!(BusinessUser, BusinessUserId), BusinessUserRepository {

  bool existsByUsername(TenantId tenantId, SystemInstanceId systemId, string username) {
    return findBySystem(tenantId, systemId).any!(e => e.username == username);
  }

  BusinessUser findByUsername(TenantId tenantId, SystemInstanceId systemId, string username) {
    foreach (e; findBySystem(tenantId, systemId))
      if (e.username == username)
        return e;
    return BusinessUser.init;
  }

  void removeByUsername(TenantId tenantId, SystemInstanceId systemId, string username) {
    auto user = findByUsername(tenantId, systemId, username);
    if (!user.isNull) {
      remove(user);
    }
  }

  bool existsByEmail(TenantId tenantId, SystemInstanceId systemId, string email) {
    return findBySystem(tenantId, systemId).any!(e => e.email == email);
  }

  BusinessUser findByEmail(TenantId tenantId, SystemInstanceId systemId, string email) {
    foreach (e; findBySystem(tenantId, systemId))
      if (e.email == email)
        return e;
    return BusinessUser.init;
  }

  void removeByEmail(TenantId tenantId, SystemInstanceId systemId, string email) {
    remove(findByEmail(tenantId, systemId, email));
  }

  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  BusinessUser[] filterBySystem(BusinessUser[] users, SystemInstanceId systemId) {
    return users.filter!(e => e.systemInstanceId == systemId).array;
  }

  BusinessUser[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }

}
