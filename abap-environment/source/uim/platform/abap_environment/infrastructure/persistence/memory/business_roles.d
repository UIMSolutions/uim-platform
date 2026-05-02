/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.persistence.memory.business_roles;

// import uim.platform.abap_environment.domain.types;
// import uim.platform.abap_environment.domain.entities.business_role;
// import uim.platform.abap_environment.domain.ports.repositories.business_role;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryBusinessRoleRepository : TenantRepository!(BusinessRole, BusinessRoleId), BusinessRoleRepository {

bool existsByName(SystemInstanceId systemId, string name) {
    foreach (e; findAll())
      if (e.systemInstanceId == systemId && e.name == name)
        return true;
    return false;
  }

  BusinessRole findByName(SystemInstanceId systemId, string name) {
    foreach (e; findAll())
      if (e.systemInstanceId == systemId && e.name == name)
        return e;
    return BusinessRole.init;
  }
  void removeByName(SystemInstanceId systemId, string name) {
    auto role = findByName(systemId, name);
    if (!role.isNull) {
      remove(role);
    }
  }

  size_t countBySystem(SystemInstanceId systemId) {
    return findBySystem(systemId).length;
  }

  BusinessRole[] filterBySystem(BusinessRole[] roles, SystemInstanceId systemId) {
    return roles.filter!(e => e.systemInstanceId == systemId).array;
  }

  BusinessRole[] findBySystem(SystemInstanceId systemId) {
    return findAll().filterBySystem(systemId);
  }

  void removeBySystem(SystemInstanceId systemId) {
    findBySystem(systemId).each!(e => remove(e));
  }
 

}
