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
  private AppConfiguration[AppConfigurationId] store;

  bool existsById(AppConfigurationId id) {
    return id in store ? true : false;
  }

  AppConfiguration findById(AppConfigurationId id) {
    return existsById(id) ? store[id] : AppConfiguration.init;
  }

  bool existsByKey(MobileAppId appId, string key) {
    return store.any!(c => c.appId == appId && c.key == key);
  }

  AppConfiguration findByKey(MobileAppId appId, string key) {
    foreach (c; findAll) {
      if (c.appId == appId && c.key == key)
        return c;
    }
    return AppConfiguration.init;
  }

  size_t countByApp(MobileAppId appId) {
    return store.values.filter!(c => c.appId == appId).array.length;
  }

  AppConfiguration[] findByApp(MobileAppId appId) {
    return store.values.filter!(c => c.appId == appId).array;
  }

  AppConfiguration[] findByAppAndPlatform(MobileAppId appId, AppPlatform platform) {
    return findByApp(appId).filter!(c => c.platform == platform).array;
  }

  AppConfiguration[] findByTenant(TenantId tenantId) {
    return store.values.filter!(c => c.tenantId == tenantId).array;
  }

  void save(AppConfiguration config) {
    store[config.id] = config;
  }

  void update(AppConfiguration config) {
    store[config.id] = config;
  }

  void remove(AppConfigurationId id) {
    store.remove(id);
  }
}
