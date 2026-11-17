/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.app_registration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A business app registered in the launchpad (UI5 component, URL, SAP GUI ...).
struct AppRegistration {
  mixin TenantEntity!AppId;

  string name; /// unique per tenant
  string description;
  string launchUrl; /// https://... or a relative path
  string icon;
  string vendor;
  string version_ = "1.0.0";
  AppStatus status = AppStatus.active;
  AppPlatform[] supportedPlatforms;
  string[] tags;
  string[] allowedRoles;

  string authType = "none"; /// none | saml | oauth2 | basic
  string authEndpoint;
  bool enableSso;
  string sapSystemAlias;
  string odataServiceUrl;
  string componentId;
}
