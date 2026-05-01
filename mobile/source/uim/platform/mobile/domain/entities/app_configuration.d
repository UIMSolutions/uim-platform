/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.app_configuration;

import uim.platform.mobile.domain.types;

struct AppConfiguration {
  AppConfigurationId id;
  TenantId tenantId;
  MobileAppId appId;
  string key;
  string value;
  string description;
  bool isSecret;
  AppPlatform platform;     // platform-specific or all
  long version_;
  long createdAt;
  long updatedAt;
  UserId createdBy;
  UserId updatedBy;
}
