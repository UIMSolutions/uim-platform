/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.mobile_app_repo;

import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.ports.repositories.mobile_apps;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryMobileAppRepository : MobileAppRepository {
  private MobileApp[MobileAppId] store;

  MobileApp findById(MobileAppId id) {
    if (auto p = id in store)
      return *p;
    return MobileApp.init;
  }

  MobileApp findByBundleId(string bundleId) {
    foreach (ref a; store) {
      if (a.bundleId == bundleId)
        return a;
    }
    return MobileApp.init;
  }

  MobileApp[] findByTenant(TenantId tenantId) {
    return store.values.filter!(a => a.tenantId == tenantId).array;
  }

  MobileApp[] findByPlatform(TenantId tenantId, AppPlatform platform) {
    return store.values.filter!(a => a.tenantId == tenantId && a.platform == platform).array;
  }

  void save(MobileApp app) {
    store[app.id] = app;
  }

  void update(MobileApp app) {
    store[app.id] = app;
  }

  void remove(MobileAppId id) {
    store.remove(id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.values.filter!(a => a.tenantId == tenantId).array.length;
  }
}
