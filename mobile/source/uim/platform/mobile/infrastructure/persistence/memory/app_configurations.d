/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.app_configurations;
// import uim.platform.mobile.domain.entities.app_configuration;
// import uim.platform.mobile.domain.ports.repositories.app_configurations;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryAppConfigurationRepository : TenantRepository!(AppConfiguration, AppConfigurationId), AppConfigurationRepository {
  
  bool existsByKey(TenantId tenantId, MobileAppId appId, string key) {
    return findByApp(tenantId, appId).any!(c => c.key == key);
  }

  AppConfiguration findByKey(TenantId tenantId, MobileAppId appId, string key) {
    foreach (c; findByApp(tenantId, appId)) {
      if (c.key == key)
        return c;
    }
    return AppConfiguration.init;
  }
void removeByKey(TenantId tenantId, MobileAppId appId, string key) {
    remove(findByKey(tenantId, appId, key));
  }
  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  AppConfiguration[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(c => remove(c));
  }

  // #region ByAppAndPlatform
  size_t countByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform) {
    return findByAppAndPlatform(tenantId, appId, platform).length;
  }
  AppConfiguration[] filterByAppAndPlatform(AppConfiguration[] configs, MobileAppId appId, AppPlatform platform) {
    return filterByApp(configs, appId).filter!(c => c.platform == platform).array;
  }
  AppConfiguration[] findByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform) {
    return filterByAppAndPlatform(findByApp(tenantId, appId), appId, platform);
  }
  void removeByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform) {
    findByAppAndPlatform(tenantId, appId, platform).each!(c => remove(c));
  }
  // #endregion ByAppAndPlatform

}
