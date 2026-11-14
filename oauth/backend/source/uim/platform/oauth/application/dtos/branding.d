/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.dtos.branding;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct CreateBrandingRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string name;
  string description;
  string logoUrl;
  string backgroundUrl;
  string primaryColor;
  string secondaryColor;
  string pageTitle;
  string footerText;
  string customCss;
  bool isDefault;
}

struct UpdateBrandingRequest {
  TenantId tenantId;
  UserId actor;
  BrandingConfigId id;

  Patch!string name;
  Patch!string description;
  Patch!string logoUrl;
  Patch!string backgroundUrl;
  Patch!string primaryColor;
  Patch!string secondaryColor;
  Patch!string pageTitle;
  Patch!string footerText;
  Patch!string customCss;
  Patch!bool isDefault;
}
