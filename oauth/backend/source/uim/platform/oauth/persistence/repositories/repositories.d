/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.oauth.persistence.repositories.repositories;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthClientRepository : DocumentRepository!(OAuthClient, OAuthClientId, clientToRecord, recordToClient),
IOAuthClientRepository {
  this(IDocumentStore store) {
    super(store, Collections.clients);
  }

  OAuthClient findByClientId(TenantId t, string clientId) {
    return first(t, (const OAuthClient e) => e.clientId == clientId);
  }

  OAuthClient[] findByBranding(TenantId t, string brandingId) {
    return where(t, (const OAuthClient e) => e.brandingId == brandingId);
  }
}

class OAuthScopeRepository : DocumentRepository!(OAuthScope, OAuthScopeId, scopeToRecord, recordToScope), IOAuthScopeRepository {
  this(IDocumentStore store) {
    super(store, Collections.scopes);
  }

  OAuthScope findByName(TenantId t, string name) {
    return first(t, (const OAuthScope e) => e.name == name);
  }

  OAuthScope[] findByApplication(TenantId t, string applicationId) {
    return where(t, (const OAuthScope e) => e.applicationId == applicationId);
  }
}

class AccessTokenRepository : DocumentRepository!(AccessToken, AccessTokenId, accessTokenToRecord, recordToAccessToken),
IAccessTokenRepository {
  this(IDocumentStore store) {
    super(store, Collections.accessTokens);
  }

  AccessToken findByHash(TenantId t, string tokenHash) {
    return tokenHash.length == 0 ? AccessToken.init : first(t, (const AccessToken e) => e.tokenHash == tokenHash);
  }

  AccessToken[] findByClient(TenantId t, string clientId) {
    return where(t, (const AccessToken e) => e.clientId == clientId);
  }

  AccessToken[] findByRefreshToken(TenantId t, string refreshTokenId) {
    return where(t, (const AccessToken e) => e.refreshTokenId == refreshTokenId);
  }

  AccessToken[] findByAuthorizationCode(TenantId t, string codeId) {
    return where(t, (const AccessToken e) => e.authorizationCodeId == codeId);
  }
}

class RefreshTokenRepository : DocumentRepository!(RefreshToken, RefreshTokenId, refreshTokenToRecord, recordToRefreshToken),
IRefreshTokenRepository {
  this(IDocumentStore store) {
    super(store, Collections.refreshTokens);
  }

  RefreshToken findByHash(TenantId t, string tokenHash) {
    return tokenHash.length == 0 ? RefreshToken.init : first(t, (const RefreshToken e) => e.tokenHash == tokenHash);
  }

  RefreshToken[] findByClient(TenantId t, string clientId) {
    return where(t, (const RefreshToken e) => e.clientId == clientId);
  }
}

class AuthorizationCodeRepository : DocumentRepository!(AuthorizationCode, AuthorizationCodeId, codeToRecord, recordToCode),
IAuthorizationCodeRepository {
  this(IDocumentStore store) {
    super(store, Collections.authorizationCodes);
  }

  AuthorizationCode findByHash(TenantId t, string codeHash) {
    return codeHash.length == 0 ? AuthorizationCode.init : first(t, (const AuthorizationCode e) => e.codeHash == codeHash);
  }

  AuthorizationCode[] findByClient(TenantId t, string clientId) {
    return where(t, (const AuthorizationCode e) => e.clientId == clientId);
  }
}

class BrandingConfigRepository : DocumentRepository!(BrandingConfig, BrandingConfigId, brandingToRecord, recordToBranding),
IBrandingConfigRepository {
  this(IDocumentStore store) {
    super(store, Collections.brandings);
  }

  BrandingConfig findByName(TenantId t, string name) {
    return first(t, (const BrandingConfig e) => e.name == name);
  }

  BrandingConfig findDefault(TenantId t) {
    return first(t, (const BrandingConfig e) => e.isDefault);
  }
}

/// All repositories over one document store.
OAuthRepositories createRepositories(IDocumentStore store) {
  OAuthRepositories r;
  r.clients = new OAuthClientRepository(store);
  r.scopes = new OAuthScopeRepository(store);
  r.accessTokens = new AccessTokenRepository(store);
  r.refreshTokens = new RefreshTokenRepository(store);
  r.codes = new AuthorizationCodeRepository(store);
  r.brandings = new BrandingConfigRepository(store);
  return r;
}
