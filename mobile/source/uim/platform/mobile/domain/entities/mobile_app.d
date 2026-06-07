/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.mobile_app;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

struct MobileApp {
  mixin TenantEntity!(MobileAppId);

  string name; // e.g. "My Mobile App"
  string description; // optional app description
  string bundleId; // e.g. "com.example.myapp", must be unique within tenant
  AppPlatform platform; // e.g. iOS, Android
  AppStatus status; // e.g. Active, Inactive, Deleted
  string securityConfig; // JSON string with security settings (e.g. allowed origins, CORS config)
  string authProvider; //  e.g. "Firebase", "Auth0", "Custom"
  bool pushEnabled;
  bool offlineEnabled;
  string iconUrl;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("bundleId", bundleId)
      .set("platform", platform)
      .set("status", status)
      .set("securityConfig", securityConfig)
      .set("authProvider", authProvider)
      .set("pushEnabled", pushEnabled)
      .set("offlineEnabled", offlineEnabled)
      .set("iconUrl", iconUrl);
  }
}
