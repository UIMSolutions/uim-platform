/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mappers.
module uim.platform.oauth.persistence.mappers.entities;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

// ── OAuthClient ───────────────────────────────────────────────────────────
Json clientToRecord(const OAuthClient e) {
  auto d = auditRecord(e);
  d["clientId"] = e.clientId;
  d["secretHash"] = e.secretHash;
  d["secretSalt"] = e.secretSalt;
  d["secretRotatedAt"] = e.secretRotatedAt;
  d["name"] = e.name;
  d["description"] = e.description;
  d["clientType"] = cast(string) e.clientType;
  d["status"] = cast(string) e.status;
  d["redirectUris"] = textsJson(e.redirectUris);
  d["allowedScopes"] = textsJson(e.allowedScopes);
  d["grantTypes"] = textsJson(enumTexts(e.grantTypes));
  d["accessTokenValidity"] = e.accessTokenValidity;
  d["refreshTokenValidity"] = e.refreshTokenValidity;
  d["contacts"] = textsJson(e.contacts);
  d["brandingId"] = e.brandingId;
  return d;
}

OAuthClient recordToClient(Json d) {
  OAuthClient e;
  readAudit!(OAuthClient, OAuthClientId)(e, d);
  e.clientId = textField(d, "clientId");
  e.secretHash = textField(d, "secretHash");
  e.secretSalt = textField(d, "secretSalt");
  e.secretRotatedAt = longField(d, "secretRotatedAt");
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.clientType = enumField(d, "clientType", ClientType.confidential);
  e.status = enumField(d, "status", ClientStatus.active);
  e.redirectUris = textsField(d, "redirectUris");
  e.allowedScopes = textsField(d, "allowedScopes");
  e.grantTypes = enumsField!GrantType(d, "grantTypes");
  e.accessTokenValidity = longField(d, "accessTokenValidity", 3600);
  e.refreshTokenValidity = longField(d, "refreshTokenValidity", 86_400);
  e.contacts = textsField(d, "contacts");
  e.brandingId = textField(d, "brandingId");
  return e;
}

// ── OAuthScope ────────────────────────────────────────────────────────────
Json scopeToRecord(const OAuthScope e) {
  auto d = auditRecord(e);
  d["applicationId"] = e.applicationId;
  d["name"] = e.name;
  d["description"] = e.description;
  d["status"] = cast(string) e.status;
  return d;
}

OAuthScope recordToScope(Json d) {
  OAuthScope e;
  readAudit!(OAuthScope, OAuthScopeId)(e, d);
  e.applicationId = textField(d, "applicationId");
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.status = enumField(d, "status", ScopeStatus.active);
  return e;
}

// ── AccessToken ───────────────────────────────────────────────────────────
Json accessTokenToRecord(const AccessToken e) {
  auto d = auditRecord(e);
  d["tokenHash"] = e.tokenHash;
  d["clientId"] = e.clientId;
  d["userId"] = e.userId;
  d["scopes"] = textsJson(e.scopes);
  d["grantType"] = cast(string) e.grantType;
  d["status"] = cast(string) e.status;
  d["issuedAt"] = e.issuedAt;
  d["expiresAt"] = e.expiresAt;
  d["revokedAt"] = e.revokedAt;
  d["revocationReason"] = cast(string) e.revocationReason;
  d["refreshTokenId"] = e.refreshTokenId;
  d["authorizationCodeId"] = e.authorizationCodeId;
  return d;
}

AccessToken recordToAccessToken(Json d) {
  AccessToken e;
  readAudit!(AccessToken, AccessTokenId)(e, d);
  e.tokenHash = textField(d, "tokenHash");
  e.clientId = textField(d, "clientId");
  e.userId = textField(d, "userId");
  e.scopes = textsField(d, "scopes");
  e.grantType = enumField(d, "grantType", GrantType.clientCredentials);
  e.status = enumField(d, "status", TokenStatus.active);
  e.issuedAt = longField(d, "issuedAt");
  e.expiresAt = longField(d, "expiresAt");
  e.revokedAt = longField(d, "revokedAt");
  e.revocationReason = enumField(d, "revocationReason", RevocationReason.none);
  e.refreshTokenId = textField(d, "refreshTokenId");
  e.authorizationCodeId = textField(d, "authorizationCodeId");
  return e;
}

// ── RefreshToken ──────────────────────────────────────────────────────────
Json refreshTokenToRecord(const RefreshToken e) {
  auto d = auditRecord(e);
  d["tokenHash"] = e.tokenHash;
  d["clientId"] = e.clientId;
  d["userId"] = e.userId;
  d["scopes"] = textsJson(e.scopes);
  d["accessTokenId"] = e.accessTokenId;
  d["replacedById"] = e.replacedById;
  d["status"] = cast(string) e.status;
  d["issuedAt"] = e.issuedAt;
  d["expiresAt"] = e.expiresAt;
  d["revokedAt"] = e.revokedAt;
  d["revocationReason"] = cast(string) e.revocationReason;
  return d;
}

RefreshToken recordToRefreshToken(Json d) {
  RefreshToken e;
  readAudit!(RefreshToken, RefreshTokenId)(e, d);
  e.tokenHash = textField(d, "tokenHash");
  e.clientId = textField(d, "clientId");
  e.userId = textField(d, "userId");
  e.scopes = textsField(d, "scopes");
  e.accessTokenId = textField(d, "accessTokenId");
  e.replacedById = textField(d, "replacedById");
  e.status = enumField(d, "status", TokenStatus.active);
  e.issuedAt = longField(d, "issuedAt");
  e.expiresAt = longField(d, "expiresAt");
  e.revokedAt = longField(d, "revokedAt");
  e.revocationReason = enumField(d, "revocationReason", RevocationReason.none);
  return e;
}

// ── AuthorizationCode ─────────────────────────────────────────────────────
Json codeToRecord(const AuthorizationCode e) {
  auto d = auditRecord(e);
  d["codeHash"] = e.codeHash;
  d["clientId"] = e.clientId;
  d["userId"] = e.userId;
  d["redirectUri"] = e.redirectUri;
  d["scopes"] = textsJson(e.scopes);
  d["codeChallenge"] = e.codeChallenge;
  d["codeChallengeMethod"] = cast(string) e.codeChallengeMethod;
  d["status"] = cast(string) e.status;
  d["issuedAt"] = e.issuedAt;
  d["expiresAt"] = e.expiresAt;
  d["usedAt"] = e.usedAt;
  return d;
}

AuthorizationCode recordToCode(Json d) {
  AuthorizationCode e;
  readAudit!(AuthorizationCode, AuthorizationCodeId)(e, d);
  e.codeHash = textField(d, "codeHash");
  e.clientId = textField(d, "clientId");
  e.userId = textField(d, "userId");
  e.redirectUri = textField(d, "redirectUri");
  e.scopes = textsField(d, "scopes");
  e.codeChallenge = textField(d, "codeChallenge");
  e.codeChallengeMethod = enumField(d, "codeChallengeMethod", CodeChallengeMethod.none);
  e.status = enumField(d, "status", AuthCodeStatus.active);
  e.issuedAt = longField(d, "issuedAt");
  e.expiresAt = longField(d, "expiresAt");
  e.usedAt = longField(d, "usedAt");
  return e;
}

// ── BrandingConfig ────────────────────────────────────────────────────────
Json brandingToRecord(const BrandingConfig e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["description"] = e.description;
  d["logoUrl"] = e.logoUrl;
  d["backgroundUrl"] = e.backgroundUrl;
  d["primaryColor"] = e.primaryColor;
  d["secondaryColor"] = e.secondaryColor;
  d["pageTitle"] = e.pageTitle;
  d["footerText"] = e.footerText;
  d["customCss"] = e.customCss;
  d["isDefault"] = e.isDefault;
  return d;
}

BrandingConfig recordToBranding(Json d) {
  BrandingConfig e;
  readAudit!(BrandingConfig, BrandingConfigId)(e, d);
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.logoUrl = textField(d, "logoUrl");
  e.backgroundUrl = textField(d, "backgroundUrl");
  e.primaryColor = textField(d, "primaryColor");
  e.secondaryColor = textField(d, "secondaryColor");
  e.pageTitle = textField(d, "pageTitle");
  e.footerText = textField(d, "footerText");
  e.customCss = textField(d, "customCss");
  e.isDefault = boolField(d, "isDefault");
  return e;
}

///
unittest {
  OAuthClient c;
  c.id = OAuthClientId("c1");
  c.tenantId = TenantId("t");
  c.clientId = "app";
  c.grantTypes = [GrantType.authorizationCode, GrantType.refreshToken];
  c.redirectUris = ["https://x.example.com/cb"];
  auto back = recordToClient(clientToRecord(c));
  assert(back.grantTypes == c.grantTypes && back.redirectUris == c.redirectUris && back.clientId == "app");

  AuthorizationCode code;
  code.codeChallengeMethod = CodeChallengeMethod.s256;
  assert(recordToCode(codeToRecord(code)).codeChallengeMethod == CodeChallengeMethod.s256);
  assert(recordToCode(codeToRecord(AuthorizationCode.init)).codeChallengeMethod == CodeChallengeMethod.none);
}
