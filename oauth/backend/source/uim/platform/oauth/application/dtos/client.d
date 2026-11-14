/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.dtos.client;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct CreateClientRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional, generated if empty

  string clientId; /// optional, generated ("sb-<id>") if empty
  string name;
  string description;
  string clientType; /// confidential (default) | public
  string[] redirectUris;
  string[] allowedScopes;
  string[] grantTypes; /// default: client_credentials (confidential) / authorization_code (public)
  long accessTokenValidity; /// 0 = default
  long refreshTokenValidity; /// 0 = default
  string[] contacts;
  string brandingId;
}

struct UpdateClientRequest {
  TenantId tenantId;
  UserId actor;
  OAuthClientId id;

  Patch!string name;
  Patch!string description;
  Patch!string status;
  Patch!string brandingId;
  Patch!(string[]) redirectUris;
  Patch!(string[]) allowedScopes;
  Patch!(string[]) grantTypes;
  Patch!(string[]) contacts;
  Patch!long accessTokenValidity;
  Patch!long refreshTokenValidity;
}

/// A client with its plain secret — returned exactly once (create / rotate).
struct ClientCredentials {
  OAuthClient client;
  string clientSecret; /// "" for public clients
  size_t revokedTokens; /// rotate: tokens revoked together with the old secret
}
