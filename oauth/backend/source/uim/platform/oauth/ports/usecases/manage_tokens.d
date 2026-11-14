/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.ports.usecases.manage_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Administration of issued tokens and codes.
interface IManageTokens {
  AccessToken[] listAccessTokens(TenantId tenantId);
  AccessToken getAccessToken(TenantId tenantId, AccessTokenId id);
  RevocationResult revokeAccessToken(TenantId tenantId, AccessTokenId id, RevocationReason reason);
  void deleteAccessToken(TenantId tenantId, AccessTokenId id);

  RefreshToken[] listRefreshTokens(TenantId tenantId);
  RefreshToken getRefreshToken(TenantId tenantId, RefreshTokenId id);
  /// Also revokes the access tokens issued with the refresh token.
  RevocationResult revokeRefreshToken(TenantId tenantId, RefreshTokenId id, RevocationReason reason);
  void deleteRefreshToken(TenantId tenantId, RefreshTokenId id);

  AuthorizationCode[] listAuthorizationCodes(TenantId tenantId);
  AuthorizationCode getAuthorizationCode(TenantId tenantId, AuthorizationCodeId id);
  void deleteAuthorizationCode(TenantId tenantId, AuthorizationCodeId id);

  /// Revoke every active token and code of a client.
  RevocationResult revokeClientTokens(TenantId tenantId, string clientId, RevocationReason reason);

  /// Remove expired / revoked tokens and used / expired codes.
  RevocationResult purgeExpired(TenantId tenantId);
}
