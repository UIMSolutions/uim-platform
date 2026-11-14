/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.tokens;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: OAuth 2.0 / OIDC token lifecycle.
interface ITokenUseCase {
  TokenResponse issueTokens(TokenRequest request);
  /// refresh_token grant with refresh token rotation.
  TokenResponse refreshTokens(RefreshRequest request);
  TokenIntrospection introspect(TenantId tenantId, string token);
  /// Revoke a token by value (RFC 7009).
  UsecaseResult revoke(TenantId tenantId, string token);
  /// OIDC userinfo for an access token (Json(null) if the token is not active).
  Json userInfo(TenantId tenantId, string accessToken);

  Token[] listTokens(TenantId tenantId);
  Token[] listByUser(TenantId tenantId, UserId userId);
  Token getToken(TenantId tenantId, TokenId id);
  UsecaseResult revokeToken(TenantId tenantId, TokenId id);
  UsecaseResult revokeAllForUser(TenantId tenantId, UserId userId);
  UsecaseResult purgeExpired(TenantId tenantId);
}
