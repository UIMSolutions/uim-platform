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

class MemoryBusinessRoleRepository : MemoryTenantRepository!(BusinessRole, BusinessRoleId), BusinessRoleRepository {
  // private BusinessRole[BusinessRoleId] store;
// 
  // BusinessRole findById(BusinessRoleId id) {
    // if (id in store)
      // return store[id];
    // return BusinessRole.init;
  // }

  BusinessRole[] findBySystem(SystemInstanceId systemId) {
    return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
  }

//  BusinessRole[] findByTenant(TenantId tenantId) {
//    return store.byValue().filter!(e => e.tenantId == tenantId).array;
//  }

  BusinessRole findByName(SystemInstanceId systemId, string name) {
    foreach (e; store.byValue())
      if (e.systemInstanceId == systemId && e.name == name)
        return e;
    return BusinessRole.init;
  }

//  void save(BusinessRole role) {
//    store[role.id] = role;
//  }
//
//  void update(BusinessRole role) {
//    store[role.id] = role;
//  }
//
//  void remove(BusinessRoleId id) {
//    store.remove(id);
//  }
}
