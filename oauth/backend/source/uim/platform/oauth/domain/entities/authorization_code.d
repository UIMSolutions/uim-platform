/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.authorization_code;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// A single use authorization code (RFC 6749 §4.1.2), bound to client,
/// redirect URI and (optionally, mandatory for public clients) a PKCE challenge.
struct AuthorizationCode {
  mixin TenantEntity!AuthorizationCodeId;

  string codeHash;
  string clientId;
  string userId;
  string redirectUri;
  string[] scopes;
  string codeChallenge;
  CodeChallengeMethod codeChallengeMethod;
  AuthCodeStatus status = AuthCodeStatus.active;
  long issuedAt;
  long expiresAt;
  long usedAt;

  AuthCodeStatus effectiveStatus(long now) const {
    if (status == AuthCodeStatus.active && isExpiredAt(expiresAt, now))
      return AuthCodeStatus.expired;
    return status;
  }

  bool isRedeemable(long now) const {
    return effectiveStatus(now) == AuthCodeStatus.active;
  }

  void markUsed(long now) {
    status = AuthCodeStatus.used;
    usedAt = now;
  }
}

///
unittest {
  AuthorizationCode c;
  c.expiresAt = 10;
  assert(c.isRedeemable(9) && !c.isRedeemable(10));
  c.markUsed(5);
  assert(c.effectiveStatus(6) == AuthCodeStatus.used && c.usedAt == 5);
}
