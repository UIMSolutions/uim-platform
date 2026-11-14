/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.oauth.ports.repositories.repositories;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface IOAuthClientRepository : IEntityRepository!(OAuthClient, OAuthClientId) {
  OAuthClient findByClientId(TenantId t, string clientId);
  OAuthClient[] findByBranding(TenantId t, string brandingId);
}

interface IOAuthScopeRepository : IEntityRepository!(OAuthScope, OAuthScopeId) {
  OAuthScope findByName(TenantId t, string name);
  OAuthScope[] findByApplication(TenantId t, string applicationId);
}

interface IAccessTokenRepository : IEntityRepository!(AccessToken, AccessTokenId) {
  AccessToken findByHash(TenantId t, string tokenHash);
  AccessToken[] findByClient(TenantId t, string clientId);
  AccessToken[] findByRefreshToken(TenantId t, string refreshTokenId);
  AccessToken[] findByAuthorizationCode(TenantId t, string codeId);
}

interface IRefreshTokenRepository : IEntityRepository!(RefreshToken, RefreshTokenId) {
  RefreshToken findByHash(TenantId t, string tokenHash);
  RefreshToken[] findByClient(TenantId t, string clientId);
}

interface IAuthorizationCodeRepository : IEntityRepository!(AuthorizationCode, AuthorizationCodeId) {
  AuthorizationCode findByHash(TenantId t, string codeHash);
  AuthorizationCode[] findByClient(TenantId t, string clientId);
}

interface IBrandingConfigRepository : IEntityRepository!(BrandingConfig, BrandingConfigId) {
  BrandingConfig findByName(TenantId t, string name);
  BrandingConfig findDefault(TenantId t);
}

/// All repositories (passed to the interactors as one bundle).
struct OAuthRepositories {
  IOAuthClientRepository clients;
  IOAuthScopeRepository scopes;
  IAccessTokenRepository accessTokens;
  IRefreshTokenRepository refreshTokens;
  IAuthorizationCodeRepository codes;
  IBrandingConfigRepository brandings;
}
