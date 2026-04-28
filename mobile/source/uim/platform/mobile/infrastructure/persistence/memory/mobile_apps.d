/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.mobile_app;

import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.ports.repositories.mobile_apps;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryMobileAppRepository : TenantRepository!(MobileApp, MobileAppId), MobileAppRepository {


  bool existsByBundleId(string bundleId) {
    return findByBundleId(bundleId).id != MobileAppId.init;
  }
  MobileApp findByBundleId(string bundleId) {
    foreach (a; findAll) {
      if (a.bundleId == bundleId)
        return a;
    }
    return MobileApp.init;
  }

  size_t countByPlatform(TenantId tenantId, AppPlatform platform) {
    return findByPlatform(tenantId, platform).length;
  }
  MobileApp[] filterByPlatform(MobileApp[] apps, AppPlatform platform) {
    return apps.filter!(e => e.platform == platform).array;
  }
  MobileApp[] findByPlatform(TenantId tenantId, AppPlatform platform) {
    return filterByPlatform(findByTenant(tenantId), platform);
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

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }
}
