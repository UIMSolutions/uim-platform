/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Secret hashes,
/// token hashes and PKCE challenges are never serialized; a plain client
/// secret appears only in the create / rotate response.
module uim.platform.oauth.presentation.odata.serializers;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime - stdTime % hnsecsPerSecond, UTC());
  return Json(t.toISOExtString);
}

Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

private Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional references).
private Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

Json clientRow(const OAuthClient e, size_t activeTokens = 0, string plainSecret = "") {
  auto j = auditRow(e);
  j["clientId"] = e.clientId;
  j["name"] = e.name;
  j["description"] = e.description;
  j["clientType"] = cast(string) e.clientType;
  j["status"] = cast(string) e.status;
  j["redirectUris"] = texts(e.redirectUris);
  j["allowedScopes"] = texts(e.allowedScopes);
  j["grantTypes"] = texts(enumTexts(e.grantTypes));
  j["accessTokenValidity"] = e.accessTokenValidity;
  j["refreshTokenValidity"] = e.refreshTokenValidity;
  j["contacts"] = texts(e.contacts);
  j["brandingId"] = textOrNull(e.brandingId);
  j["hasSecret"] = e.hasSecret;
  j["secretRotatedAt"] = isoTime(e.secretRotatedAt);
  j["clientSecret"] = textOrNull(plainSecret);
  j["activeTokens"] = activeTokens;
  return j;
}

Json scopeRow(const OAuthScope e, size_t clientCount = 0) {
  auto j = auditRow(e);
  j["applicationId"] = e.applicationId;
  j["name"] = e.name;
  j["description"] = e.description;
  j["status"] = cast(string) e.status;
  j["clientCount"] = clientCount;
  return j;
}

Json accessTokenRow(const AccessToken e, long now) {
  auto j = auditRow(e);
  j["clientId"] = e.clientId;
  j["userId"] = textOrNull(e.userId);
  j["scopes"] = texts(e.scopes);
  j["grantType"] = cast(string) e.grantType;
  j["status"] = cast(string) e.effectiveStatus(now);
  j["issuedAt"] = isoTime(e.issuedAt);
  j["expiresAt"] = isoTime(e.expiresAt);
  j["revokedAt"] = isoTime(e.revokedAt);
  j["revocationReason"] = textOrNull(cast(string) e.revocationReason);
  j["refreshTokenId"] = textOrNull(e.refreshTokenId);
  j["authorizationCodeId"] = textOrNull(e.authorizationCodeId);
  return j;
}

Json refreshTokenRow(const RefreshToken e, long now) {
  auto j = auditRow(e);
  j["clientId"] = e.clientId;
  j["userId"] = textOrNull(e.userId);
  j["scopes"] = texts(e.scopes);
  j["accessTokenId"] = textOrNull(e.accessTokenId);
  j["replacedById"] = textOrNull(e.replacedById);
  j["status"] = cast(string) e.effectiveStatus(now);
  j["issuedAt"] = isoTime(e.issuedAt);
  j["expiresAt"] = isoTime(e.expiresAt);
  j["revokedAt"] = isoTime(e.revokedAt);
  j["revocationReason"] = textOrNull(cast(string) e.revocationReason);
  return j;
}

Json codeRow(const AuthorizationCode e, long now) {
  auto j = auditRow(e);
  j["clientId"] = e.clientId;
  j["userId"] = e.userId;
  j["redirectUri"] = e.redirectUri;
  j["scopes"] = texts(e.scopes);
  j["codeChallengeMethod"] = textOrNull(cast(string) e.codeChallengeMethod);
  j["status"] = cast(string) e.effectiveStatus(now);
  j["issuedAt"] = isoTime(e.issuedAt);
  j["expiresAt"] = isoTime(e.expiresAt);
  j["usedAt"] = isoTime(e.usedAt);
  return j;
}

Json brandingRow(const BrandingConfig e, size_t clientCount = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["logoUrl"] = e.logoUrl;
  j["backgroundUrl"] = e.backgroundUrl;
  j["primaryColor"] = e.primaryColor;
  j["secondaryColor"] = e.secondaryColor;
  j["pageTitle"] = e.pageTitle;
  j["footerText"] = e.footerText;
  j["customCss"] = e.customCss;
  j["isDefault"] = e.isDefault;
  j["clientCount"] = clientCount;
  return j;
}

Json statisticsRow(const OAuthStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId;
  static foreach (name; ["clients", "activeClients", "blockedClients", "publicClients", "scopes", "activeAccessTokens",
      "expiredAccessTokens", "revokedAccessTokens", "activeRefreshTokens", "pendingAuthorizationCodes", "brandings"])
    j[name] = __traits(getMember, s, name);
  return j;
}

Json clientSecretRow(const ClientCredentials c) {
  auto j = Json.emptyObject;
  j["id"] = c.client.id.value;
  j["clientId"] = c.client.clientId;
  j["clientSecret"] = c.clientSecret;
  j["secretRotatedAt"] = isoTime(c.client.secretRotatedAt);
  j["revokedTokens"] = c.revokedTokens;
  return j;
}

Json revocationRow(const RevocationResult r) {
  auto j = Json.emptyObject;
  j["accessTokens"] = r.accessTokens;
  j["refreshTokens"] = r.refreshTokens;
  j["codes"] = r.codes;
  return j;
}

Json tokenResultRow(const TokenResponse t) {
  auto j = Json.emptyObject;
  j["accessToken"] = t.accessToken;
  j["tokenType"] = t.tokenType;
  j["expiresIn"] = t.expiresIn;
  j["refreshToken"] = textOrNull(t.refreshToken);
  j["scope"] = joinScopes(t.scopes);
  j["jti"] = t.record.id.value;
  return j;
}

Json introspectionRow(const IntrospectionResult r) {
  auto j = Json.emptyObject;
  j["active"] = r.active;
  j["tokenType"] = textOrNull(r.tokenType);
  j["clientId"] = textOrNull(r.clientId);
  j["userId"] = textOrNull(r.userId);
  j["scope"] = joinScopes(r.scopes);
  j["status"] = textOrNull(r.status);
  j["issuedAt"] = isoTime(r.issuedAt);
  j["expiresAt"] = isoTime(r.expiresAt);
  j["jti"] = textOrNull(r.jti);
  return j;
}

///
unittest {
  OAuthClient c;
  c.id = OAuthClientId("c1");
  c.secretHash = "deadbeef";
  auto row = clientRow(c);
  assert("secretHash" !in row && "secretSalt" !in row && row["hasSecret"].get!bool);
  assert(row["clientSecret"].type == Json.Type.null_);
  AccessToken t;
  t.tokenHash = "x";
  assert("tokenHash" !in accessTokenRow(t, 0));
  assert(isoTime(0).type == Json.Type.null_);
}
