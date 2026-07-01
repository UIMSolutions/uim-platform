/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.roles;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryRoleRepository : TenantRepository!(RoleEntity, RoleId), RoleRepository {

  bool existsByName(TenantId tenantId, string name, string appId) {
    return findByTenant(tenantId).any!(r => r.name == name && r.appId == appId);
  }

  RoleEntity findByName(TenantId tenantId, string name, string appId) {
    foreach (r; findByTenant(tenantId))
      if (r.name == name && r.appId == appId)
        return r;
    return RoleEntity.init;
  }

  void removeByName(TenantId tenantId, string name, string appId) {
    remove(findByName(tenantId, name, appId));
  }

  size_t countByApp(TenantId tenantId, string appId) {
    return findByTenant(tenantId).count!(r => r.appId == appId);
  }

  RoleEntity[] filterByApp(TenantId tenantId, RoleEntity[] roles, string appId) {
    return roles.filter!(r => r.appId == appId).array;
  }

  RoleEntity[] findByApp(TenantId tenantId, string appId) {
    return findByTenant(tenantId).filter!(r => r.appId == appId).array;
  }

  void removeByApp(TenantId tenantId, string appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

}
