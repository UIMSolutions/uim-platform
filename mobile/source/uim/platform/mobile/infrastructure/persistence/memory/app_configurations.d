/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.app_configurations;

import uim.platform.mobile.domain.entities.app_configuration;
import uim.platform.mobile.domain.ports.repositories.app_configurations;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryAppConfigurationRepository : TenantRepository!(AppConfiguration, AppConfigurationId), AppConfigurationRepository {
  
  bool existsByKey(MobileAppId appId, string key) {
    return findByApp(appId).any!(c => c.key == key);
  }

  AppConfiguration findByKey(MobileAppId appId, string key) {
    foreach (c; findByApp(appId)) {
      if (c.key == key)
        return c;
    }
    return AppConfiguration.init;
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }

  AppConfiguration[] filterByApp(AppConfiguration[] configs, MobileAppId appId) {
    return configs.filter!(c => c.appId == appId).array;
  }
  AppConfiguration[] findByApp(MobileAppId appId) {
    return filterByApp(findAll().array, appId);
  }

  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(c => remove(c));
  }

  size_t countByAppAndPlatform(MobileAppId appId, AppPlatform platform) {
    return findByAppAndPlatform(appId, platform).length;
  }
  AppConfiguration[] filterByAppAndPlatform(AppConfiguration[] configs, MobileAppId appId, AppPlatform platform) {
    return configs.filter!(c => c.appId == appId && c.platform == platform).array;
  }
  AppConfiguration[] findByAppAndPlatform(MobileAppId appId, AppPlatform platform) {
    return filterByAppAndPlatform(findByApp(appId), appId, platform);
  }
  void removeByAppAndPlatform(MobileAppId appId, AppPlatform platform) {
    findByAppAndPlatform(appId, platform).each!(c => remove(c));
  }

}
