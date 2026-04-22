/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_configurations;

import uim.platform.mobile.domain.entities.app_configuration;
import uim.platform.mobile.domain.types;

interface AppConfigurationRepository : ITenantRepository!(AppConfiguration, AppConfigurationId) {

  bool existsByKey(MobileAppId appId, string key);
  AppConfiguration findByKey(MobileAppId appId, string key);
  void removeByKey(MobileAppId appId, string key);

  size_t countByApp(MobileAppId appId);
  AppConfiguration[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByAppAndPlatform(MobileAppId appId, AppPlatform platform);
  AppConfiguration[] findByAppAndPlatform(MobileAppId appId, AppPlatform platform);
  void removeByAppAndPlatform(MobileAppId appId, AppPlatform platform);

}
