/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_configurations;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

interface AppConfigurationRepository : ITenantRepository!(AppConfiguration, AppConfigurationId) {

  bool existsByKey(TenantId tenantId, MobileAppId appId, string key);
  AppConfiguration findByKey(TenantId tenantId, MobileAppId appId, string key);
  void removeByKey(TenantId tenantId, MobileAppId appId, string key);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  AppConfiguration[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform);
  AppConfiguration[] findByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform);
  void removeByAppAndPlatform(TenantId tenantId, MobileAppId appId, AppPlatform platform);

}
