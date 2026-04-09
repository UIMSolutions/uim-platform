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

class MemoryClientResourceRepository : ClientResourceRepository {
  private ClientResource[ClientResourceId] store;

  ClientResource findById(ClientResourceId id) {
    if (auto p = id in store)
      return *p;
    return ClientResource.init;
  }

  ClientResource findByName(MobileAppId appId, string name) {
    foreach (ref r; store) {
      if (r.appId == appId && r.name == name)
        return r;
    }
    return ClientResource.init;
  }

  ClientResource[] findByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  ClientResource[] findByType(MobileAppId appId, ClientResourceType type) {
    return store.values.filter!(r => r.appId == appId && r.type == type).array;
  }

  ClientResource[] findByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array;
  }

  void save(ClientResource resource) {
    store[resource.id] = resource;
  }

  void update(ClientResource resource) {
    store[resource.id] = resource;
  }

  void remove(ClientResourceId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(r => r.appId == appId).array.length;
  }
}
