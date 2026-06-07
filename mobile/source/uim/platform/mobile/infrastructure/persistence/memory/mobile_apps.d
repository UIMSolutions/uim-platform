/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.mobile_apps;
// import uim.platform.mobile.domain.entities.mobile_app;
// import uim.platform.mobile.domain.ports.repositories.mobile_apps;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryMobileAppRepository : TenantRepository!(MobileApp, MobileAppId), MobileAppRepository {

  size_t countByBundleId(TenantId tenantId, string bundleId) {
    return findByBundleId(tenantId, bundleId).length;
  }

  bool existsByBundleId(TenantId tenantId, string bundleId) {
    return findByBundleId(tenantId, bundleId).id != MobileAppId.init;
  }
  MobileApp findByBundleId(TenantId tenantId, string bundleId) {
    foreach (a; findByTenant(tenantId)) {
      if (a.bundleId == bundleId)
        return a;
    }
    return MobileApp.init;
  }
  void removeByBundleId(TenantId tenantId, string bundleId) {
    foreach (a; findByTenant(tenantId)) {
      if (a.bundleId == bundleId)
        remove(a);
    }
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
  void removeByPlatform(TenantId tenantId, AppPlatform platform) {
    findByPlatform(tenantId, platform).each!(a => remove(a));
  }

}
