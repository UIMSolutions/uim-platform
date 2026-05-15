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
// 
//  

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

class MemoryBusinessRoleRepository : TenantRepository!(BusinessRole, BusinessRoleId), BusinessRoleRepository {

  // #region ByName
  bool existsByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    return findBySystem(tenantId, systemId).any!(e => e.name == name);
  }

  BusinessRole findByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    foreach (e; findBySystem(tenantId, systemId))
      if (e.name == name)
        return e;
    return BusinessRole.init;
  }

  void removeByName(TenantId tenantId, SystemInstanceId systemId, string name) {
    auto role = findByName(tenantId, systemId, name);
    if (!role.isNull) {
      remove(role);
    }
  }
  // #endregion ByName

  // #region BySystem
  size_t countBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  BusinessRole[] filterBySystem(BusinessRole[] roles, SystemInstanceId systemId) {
    return roles.filter!(e => e.systemInstanceId == systemId).array;
  }

  BusinessRole[] findBySystem(TenantId tenantId, SystemInstanceId systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, SystemInstanceId systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e));
  }
  // #endregion BySystem

}
