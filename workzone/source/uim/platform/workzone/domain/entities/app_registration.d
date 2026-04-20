/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.app_registration;

import uim.platform.workzone.domain.types;

/// A registered business application — SAP or third-party app entry.
struct AppRegistration {
  AppId id;
  TenantId tenantId;
  string name;
  string description;
  string launchUrl;
  string icon;
  string vendor;
  string version_;
  AppStatus status = AppStatus.active;
  string[] supportedPlatforms; // "web", "mobile", "desktop"
  string[] tags;
  RoleId[] allowedRoleIds;
  AppConfig appConfig;
  long createdAt;
  long updatedAt;
}

/// App-specific configuration.
struct AppConfig {
  string authType; // "saml", "oauth2", "basic", "none"
  string authEndpoint;
  bool enableSso;
  string sapSystemAlias;
  string oDataServiceUrl;
  string componentId;

  Json toJson() const {
      return Json()
          .set("authType", authType)
          .set("authEndpoint", authEndpoint)
          .set("enableSso", enableSso)
          .set("sapSystemAlias", sapSystemAlias)
          .set("oDataServiceUrl", oDataServiceUrl)
          .set("componentId", componentId);
  }
}
