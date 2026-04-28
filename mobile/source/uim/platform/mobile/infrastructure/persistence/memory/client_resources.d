/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.client_resource;

import uim.platform.mobile.domain.entities.client_resource;
import uim.platform.mobile.domain.ports.repositories.client_resources;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryClientResourceRepository : TenantRepository!(ClientResource, ClientResourceId), ClientResourceRepository {
  
  bool existsByName(MobileAppId appId, string name) {
    return findAll()().any!(r => r.appId == appId && r.name == name);
  }

  ClientResource findByName(MobileAppId appId, string name) {
      foreach (r; findAll()) {
        if (r.appId == appId && r.name == name)
        return r;
    }
    return ClientResource.init;
  }

  size_t count() {
    return findAll()().values.length;
  }
  ClientResource[] filterByApp(ClientResource[] resources, MobileAppId appId)  {
    return resources.filter!(r => r.appId == appId).array;
  }
  ClientResource[] findByApp(MobileAppId appId) {
    return filterByApp(findAll()().values.array, appId);
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(r => remove(r));
  }

  size_t countByType(MobileAppId appId, ClientResourceType type) {
    return findByType(appId, type).length;
  }
  ClientResource[] filterByType(ClientResource[] resources, ClientResourceType type) {
    return resources.filter!(r => r.type == type).array;
  }
  ClientResource[] findByType(MobileAppId appId, ClientResourceType type) {
    return filterByType(findByApp(appId), type);
  }
  void removeByType(MobileAppId appId, ClientResourceType type) {
    findByType(appId, type).each!(r => remove(r));
  }

}
