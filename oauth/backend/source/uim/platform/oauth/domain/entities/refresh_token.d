/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.refresh_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// An opaque refresh token (hash stored). Refresh tokens are rotated on
/// every use; replacedById links the chain so replays can be detected.
struct RefreshToken {
  mixin TenantEntity!RefreshTokenId;

  string tokenHash;
  string clientId;
  string userId;
  string[] scopes;
  string accessTokenId; /// latest access token issued with it
  string replacedById; /// successor after rotation
  TokenStatus status = TokenStatus.active;
  long issuedAt;
  long expiresAt;
  long revokedAt;
  RevocationReason revocationReason;

  TokenStatus effectiveStatus(long now) const {
    if (status == TokenStatus.active && isExpiredAt(expiresAt, now))
      return TokenStatus.expired;
    return status;
  }

  bool isUsable(long now) const {
    return effectiveStatus(now) == TokenStatus.active;
  }

  bool revoke(RevocationReason reason, long now) {
    if (status != TokenStatus.active)
      return false;
    status = TokenStatus.revoked;
    revocationReason = reason;
    revokedAt = now;
    return true;
  }

  /// True if it was rotated already (presenting it again is a replay).
  bool wasRotated() const {
    return status == TokenStatus.revoked && revocationReason == RevocationReason.rotated;
  }
}

///
unittest {
  RefreshToken t;
  t.expiresAt = 100;
  assert(t.isUsable(1));
  t.revoke(RevocationReason.rotated, 2);
  assert(t.wasRotated && !t.isUsable(3));
}
