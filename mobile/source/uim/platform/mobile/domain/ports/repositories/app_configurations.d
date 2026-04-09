/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_configurations;

import uim.platform.mobile.domain.entities.app_configuration;
import uim.platform.mobile.domain.types;

interface AppConfigurationRepository {
  AppConfiguration findById(AppConfigurationId id);
  AppConfiguration findByKey(MobileAppId appId, string key);
  AppConfiguration[] findByApp(MobileAppId appId);
  AppConfiguration[] findByAppAndPlatform(MobileAppId appId, AppPlatform platform);
  AppConfiguration[] findByTenant(TenantId tenantId);
  void save(AppConfiguration config);
  void update(AppConfiguration config);
  void remove(AppConfigurationId id);
  size_t countByApp(MobileAppId appId);
}
