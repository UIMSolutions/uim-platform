/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.scopes;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class MemoryScopeRepository : TenantRepository!(ScopeEntity, ScopeId), ScopeRepository {

  bool existsByName(TenantId tenantId, string name) {
    return find(tenantId).any!(s => s.name == name);
  }

  ScopeEntity findByName(TenantId tenantId, string name) {
    foreach (s; find(tenantId))
      if (s.name == name)
        return s;
    return ScopeEntity.init;
  }
  void removeByName(TenantId tenantId, string name) {
    remove(findByName(tenantId, name));
  }

  size_t countByApp(TenantId tenantId, string appId) {
    return findByApp(tenantId, appId).length;
  }
  ScopeEntity[] filterByApp(ScopeEntity[] scopes, string appId) {
    return scopes.filter!(s => s.appId == appId).array;
  }
  ScopeEntity[] findByApp(TenantId tenantId, string appId) {
    return filterByApp(find(tenantId), appId);
  }
  void removeByApp(TenantId tenantId, string appId) {
    findByApp(tenantId, appId).each!(s => remove(s));
  }

}
