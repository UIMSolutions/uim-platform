/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.dtos.scope_requests;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct CreateScopeRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string applicationId;
  string name;
  string description;
}

struct UpdateScopeRequest {
  TenantId tenantId;
  UserId actor;
  OAuthScopeId id;

  Patch!string applicationId;
  Patch!string description;
  Patch!string status;
}
