/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.client_resource;
// import uim.platform.mobile.domain.entities.client_resource;
// import uim.platform.mobile.domain.ports.repositories.client_resources;
// import uim.platform.mobile.domain.types;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class MemoryClientResourceRepository : TenantRepository!(ClientResource, ClientResourceId), ClientResourceRepository {
  
  bool existsByName(TenantId tenantId, MobileAppId appId, string name) {
    return findByTenant(tenantId).any!(r => r.appId == appId && r.name == name);
  }

  ClientResource findByName(TenantId tenantId, MobileAppId appId, string name) {
      foreach (r; findByTenant(tenantId)) {
        if (r.appId == appId && r.name == name)
        return r;
    }
    return ClientResource.init;
  }
  void removeByName(TenantId tenantId, MobileAppId appId, string name) {
    remove(findByName(tenantId, appId, name));
  }

  size_t count(TenantId tenantId) {
    return findByTenant(tenantId).values.length;
  }
  ClientResource[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId).values.array, appId);
  }
  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countByType(TenantId tenantId, MobileAppId appId, ClientResourceType type) {
    return findByType(tenantId, appId, type).length;
  }
  ClientResource[] filterByType(ClientResource[] resources, ClientResourceType type) {
    return resources.filter!(r => r.type == type).array;
  }
  ClientResource[] findByType(TenantId tenantId, MobileAppId appId, ClientResourceType type) {
    return filterByType(findByApp(tenantId, appId), type);
  }
  void removeByType(TenantId tenantId, MobileAppId appId, ClientResourceType type) {
    findByType(tenantId, appId, type).each!(r => remove(r));
  }

}
