/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST
/// adapter, the CLI and the GtkD GUI.
///
/// Scopes: Read (all reads), Manage (clients, scopes, brandings, token
/// revocation and all actions).
module uim.platform.oauth.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.oauth";

ODataServiceModel oauthModel() {
  auto m = new ODataServiceModel(odataNamespace, "OAuthService", "OAuth 2.0");

  m.entitySet("OAuthClients", "OAuthClient")
    .tenantAware()
    .property("clientId", Edm.string_, "Client ID")
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("clientType", Edm.string_, "Client Type")
    .property("status", Edm.string_, "Status")
    .collection("redirectUris", Edm.string_, "Redirect URIs")
    .collection("allowedScopes", Edm.string_, "Allowed Scopes")
    .collection("grantTypes", Edm.string_, "Grant Types")
    .property("accessTokenValidity", Edm.int32, "Access Token Validity (s)")
    .property("refreshTokenValidity", Edm.int32, "Refresh Token Validity (s)")
    .collection("contacts", Edm.string_, "Contacts")
    .property("brandingId", Edm.string_, "Branding")
    .property("hasSecret", Edm.boolean, "Has Secret")
    .property("secretRotatedAt", Edm.dateTimeOffset, "Secret Rotated At")
    .property("clientSecret", Edm.string_, "Client Secret (shown once)")
    .property("activeTokens", Edm.int32, "Active Tokens")
    .computed("hasSecret", "secretRotatedAt", "clientSecret", "activeTokens")
    .immutableProps("clientId", "clientType")
    .writable()
    .titled("OAuth Client", "OAuth Clients", "name", "clientId")
    .columns("name", "clientId", "clientType", "status", "activeTokens")
    .filters("clientType", "status", "brandingId")
    .scopes("Read", "Manage");

  m.entitySet("OAuthScopes", "OAuthScope")
    .tenantAware()
    .property("applicationId", Edm.string_, "Application", false)
    .property("name", Edm.string_, "Scope", false)
    .property("description", Edm.string_, "Description")
    .property("status", Edm.string_, "Status")
    .property("clientCount", Edm.int32, "Clients")
    .computed("clientCount")
    .immutableProps("name")
    .writable()
    .titled("Scope", "Scopes", "name", "description")
    .columns("name", "applicationId", "status", "clientCount", "description")
    .filters("applicationId", "status")
    .scopes("Read", "Manage");

  m.entitySet("AccessTokens", "AccessToken")
    .tenantAware()
    .property("clientId", Edm.string_, "Client ID")
    .property("userId", Edm.string_, "User")
    .collection("scopes", Edm.string_, "Scopes")
    .property("grantType", Edm.string_, "Grant Type")
    .property("status", Edm.string_, "Status")
    .property("issuedAt", Edm.dateTimeOffset, "Issued At")
    .property("expiresAt", Edm.dateTimeOffset, "Expires At")
    .property("revokedAt", Edm.dateTimeOffset, "Revoked At")
    .property("revocationReason", Edm.string_, "Revocation Reason")
    .property("refreshTokenId", Edm.string_, "Refresh Token")
    .property("authorizationCodeId", Edm.string_, "Authorization Code")
    .writable(false, false, true)
    .titled("Access Token", "Access Tokens", "clientId", "userId")
    .columns("clientId", "userId", "grantType", "status", "issuedAt", "expiresAt")
    .filters("clientId", "userId", "status", "grantType")
    .scopes("Read", "Manage");

  m.entitySet("RefreshTokens", "RefreshToken")
    .tenantAware()
    .property("clientId", Edm.string_, "Client ID")
    .property("userId", Edm.string_, "User")
    .collection("scopes", Edm.string_, "Scopes")
    .property("accessTokenId", Edm.string_, "Access Token")
    .property("replacedById", Edm.string_, "Replaced By")
    .property("status", Edm.string_, "Status")
    .property("issuedAt", Edm.dateTimeOffset, "Issued At")
    .property("expiresAt", Edm.dateTimeOffset, "Expires At")
    .property("revokedAt", Edm.dateTimeOffset, "Revoked At")
    .property("revocationReason", Edm.string_, "Revocation Reason")
    .writable(false, false, true)
    .titled("Refresh Token", "Refresh Tokens", "clientId", "userId")
    .columns("clientId", "userId", "status", "issuedAt", "expiresAt", "revocationReason")
    .filters("clientId", "userId", "status")
    .scopes("Read", "Manage");

  m.entitySet("AuthorizationCodes", "AuthorizationCode")
    .tenantAware()
    .property("clientId", Edm.string_, "Client ID")
    .property("userId", Edm.string_, "User")
    .property("redirectUri", Edm.string_, "Redirect URI")
    .collection("scopes", Edm.string_, "Scopes")
    .property("codeChallengeMethod", Edm.string_, "PKCE Method")
    .property("status", Edm.string_, "Status")
    .property("issuedAt", Edm.dateTimeOffset, "Issued At")
    .property("expiresAt", Edm.dateTimeOffset, "Expires At")
    .property("usedAt", Edm.dateTimeOffset, "Used At")
    .writable(false, false, true)
    .titled("Authorization Code", "Authorization Codes", "clientId", "userId")
    .columns("clientId", "userId", "status", "codeChallengeMethod", "expiresAt")
    .filters("clientId", "userId", "status")
    .scopes("Read", "Manage");

  m.entitySet("BrandingConfigs", "BrandingConfig")
    .tenantAware()
    .property("name", Edm.string_, "Name", false)
    .property("description", Edm.string_, "Description")
    .property("logoUrl", Edm.string_, "Logo URL")
    .property("backgroundUrl", Edm.string_, "Background URL")
    .property("primaryColor", Edm.string_, "Primary Color")
    .property("secondaryColor", Edm.string_, "Secondary Color")
    .property("pageTitle", Edm.string_, "Page Title")
    .property("footerText", Edm.string_, "Footer Text")
    .property("customCss", Edm.string_, "Custom CSS")
    .property("isDefault", Edm.boolean, "Default")
    .property("clientCount", Edm.int32, "Clients")
    .computed("clientCount")
    .writable()
    .titled("Branding", "Brandings", "name", "pageTitle")
    .columns("name", "pageTitle", "primaryColor", "isDefault", "clientCount")
    .filters("isDefault")
    .scopes("Read", "Manage");

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("clients", Edm.int32, "Clients")
    .property("activeClients", Edm.int32, "Active Clients")
    .property("blockedClients", Edm.int32, "Blocked Clients")
    .property("publicClients", Edm.int32, "Public Clients")
    .property("scopes", Edm.int32, "Scopes")
    .property("activeAccessTokens", Edm.int32, "Active Access Tokens")
    .property("expiredAccessTokens", Edm.int32, "Expired Access Tokens")
    .property("revokedAccessTokens", Edm.int32, "Revoked Access Tokens")
    .property("activeRefreshTokens", Edm.int32, "Active Refresh Tokens")
    .property("pendingAuthorizationCodes", Edm.int32, "Pending Codes")
    .property("brandings", Edm.int32, "Brandings")
    .titled("Statistics", "Statistics")
    .scopes("Read", "");

  m.complexType("ClientSecretResult")
    .property("id", Edm.string_, "ID")
    .property("clientId", Edm.string_, "Client ID")
    .property("clientSecret", Edm.string_, "Client Secret")
    .property("secretRotatedAt", Edm.dateTimeOffset, "Rotated At")
    .property("revokedTokens", Edm.int32, "Revoked Tokens");

  m.complexType("RevocationResult")
    .property("accessTokens", Edm.int32, "Access Tokens")
    .property("refreshTokens", Edm.int32, "Refresh Tokens")
    .property("codes", Edm.int32, "Authorization Codes");

  m.complexType("TokenResult")
    .property("accessToken", Edm.string_, "Access Token")
    .property("tokenType", Edm.string_, "Token Type")
    .property("expiresIn", Edm.int32, "Expires In (s)")
    .property("refreshToken", Edm.string_, "Refresh Token")
    .property("scope", Edm.string_, "Scope")
    .property("jti", Edm.string_, "Token ID");

  m.complexType("IntrospectionResult")
    .property("active", Edm.boolean, "Active")
    .property("tokenType", Edm.string_, "Token Type")
    .property("clientId", Edm.string_, "Client ID")
    .property("userId", Edm.string_, "User")
    .property("scope", Edm.string_, "Scope")
    .property("status", Edm.string_, "Status")
    .property("issuedAt", Edm.dateTimeOffset, "Issued At")
    .property("expiresAt", Edm.dateTimeOffset, "Expires At")
    .property("jti", Edm.string_, "Token ID");

  m.action("RotateClientSecret", "ClientSecretResult")
    .parameter("id", Edm.string_, false)
    .labelled("Rotate Client Secret")
    .requires("Manage");

  m.action("RevokeClientTokens", "RevocationResult")
    .parameter("id", Edm.string_, false)
    .labelled("Revoke All Tokens of a Client")
    .requires("Manage");

  m.action("RevokeAccessToken", "RevocationResult")
    .parameter("id", Edm.string_, false)
    .labelled("Revoke Access Token")
    .requires("Manage");

  m.action("RevokeRefreshToken", "RevocationResult")
    .parameter("id", Edm.string_, false)
    .labelled("Revoke Refresh Token")
    .requires("Manage");

  m.action("RequestClientToken", "TokenResult")
    .parameter("clientId", Edm.string_, false)
    .parameter("clientSecret", Edm.string_, false)
    .parameter("scope", Edm.string_)
    .labelled("Test Client Credentials")
    .requires("Manage");

  m.action("IntrospectToken", "IntrospectionResult")
    .parameter("token", Edm.string_, false)
    .parameter("tokenTypeHint", Edm.string_)
    .labelled("Introspect Token")
    .requires("Manage");

  m.action("PurgeExpired", "RevocationResult")
    .labelled("Purge Expired Tokens")
    .requires("Manage");

  m.validate();
  return m;
}

///
unittest {
  auto m = oauthModel();
  assert(m.has("OAuthClients") && m.find("Statistics").singleton);
  assert(m.find("AccessTokens").deletable && !m.find("AccessTokens").insertable && !m.find("AccessTokens").updatable);
  assert(m.find("OAuthClients").propertyOf("clientSecret").computed);
  assert(m.findAction("RotateClientSecret").returnEdmType == "uim.oauth.ClientSecretResult");
}
