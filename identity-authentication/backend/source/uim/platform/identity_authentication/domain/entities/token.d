/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.token;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Issued security token. Only a SHA-256 hash of the token value is stored, so
/// a leaked token store cannot be replayed; tokens are looked up by that hash.
struct Token {
  mixin TenantEntity!TokenId;

  UserId userId;
  ApplicationId applicationId;
  SessionId sessionId;
  TokenType tokenType = TokenType.access;
  string tokenHash;
  string[] scopes;
  long issuedAt;
  long expiresAt;
  bool revoked;

  bool isExpired(long now) const {
    return expiresAt > 0 && expiresAt <= now;
  }

  bool isActive(long now) const {
    return !revoked && !isExpired(now);
  }

  Json toJson() const {
    return entityToJson
      .set("userId", userId.value)
      .set("applicationId", applicationId.value)
      .set("sessionId", sessionId.value)
      .set("tokenType", enumValue(tokenType))
      .set("scopes", scopes.map!(s => Json(s)).array.toJson)
      .set("issuedAt", issuedAt)
      .set("expiresAt", expiresAt)
      .set("revoked", revoked);
  }
}
///
unittest {
  mixin(ShowTest!("Token"));

  auto t = Token(TenantId("t1"));
  t.expiresAt = 100;
  assert(t.isActive(50) && !t.isActive(100));
  t.revoked = true;
  assert(!t.isActive(50));
  assert("tokenHash" !in t.toJson);
}
