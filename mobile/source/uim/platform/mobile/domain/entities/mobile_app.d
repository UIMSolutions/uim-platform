/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.mobile_app;

import uim.platform.mobile.domain.types;

struct MobileApp {
  MobileAppId id;
  TenantId tenantId;
  string name;
  string description;
  string bundleId;        // e.g. com.example.app
  AppPlatform platform;
  AppStatus status;
  string securityConfig;  // JSON security configuration
  string authProvider;    // identity provider URL
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;
  long createdAt;
  long updatedAt;
  string createdBy;
  string modifiedBy;
}
