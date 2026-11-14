/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.access_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Record of an issued JWT access token. The id is the JWT "jti"; only a
/// SHA-256 hash of the token is stored.
struct AccessToken {
  mixin TenantEntity!AccessTokenId;

  string tokenHash;
  string clientId; /// public client id
  string userId; /// "" for client_credentials tokens
  string[] scopes;
  GrantType grantType = GrantType.clientCredentials;
  TokenStatus status = TokenStatus.active;
  long issuedAt;
  long expiresAt;
  long revokedAt;
  RevocationReason revocationReason;
  string refreshTokenId; /// refresh token issued together with this token
  string authorizationCodeId; /// code this token was obtained with

  /// Status with expiry applied.
  TokenStatus effectiveStatus(long now) const {
    if (status == TokenStatus.active && isExpiredAt(expiresAt, now))
      return TokenStatus.expired;
    return status;
  }

  bool isUsable(long now) const {
    return effectiveStatus(now) == TokenStatus.active;
  }

  /// Mark revoked (idempotent; returns false if it was not active).
  bool revoke(RevocationReason reason, long now) {
    if (status != TokenStatus.active)
      return false;
    status = TokenStatus.revoked;
    revocationReason = reason;
    revokedAt = now;
    return true;
  }
}

///
unittest {
  AccessToken t;
  t.expiresAt = 100;
  assert(t.isUsable(99) && t.effectiveStatus(100) == TokenStatus.expired);
  assert(t.revoke(RevocationReason.manual, 50) && !t.revoke(RevocationReason.manual, 51));
  assert(t.effectiveStatus(10) == TokenStatus.revoked && t.revokedAt == 50);
}
