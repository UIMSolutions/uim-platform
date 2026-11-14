/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.tokens;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class TokenRepository : TenantRepository!(Token, TokenId), ITokenRepository {
  mixin TenantRepositoryTemplate!(TokenRepository, Token, TokenId);

  bool existsByHash(TenantId tenantId, string tokenHash) {
    return !findByHash(tenantId, tokenHash).isNull;
  }

  Token findByHash(TenantId tenantId, string tokenHash) {
    if (tokenHash.length == 0)
      return Token.init;
    foreach (t; findByTenant(tenantId))
      if (t.tokenHash == tokenHash)
        return t;
    return Token.init;
  }

  Token[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(t => t.userId == userId).array;
  }

  Token[] findBySession(TenantId tenantId, SessionId sessionId) {
    return findByTenant(tenantId).filter!(t => t.sessionId == sessionId).array;
  }

  void revoke(TenantId tenantId, TokenId id) {
    auto t = findById(tenantId, id);
    if (t.isNull || t.revoked)
      return;
    t.revoked = true;
    update(t);
  }

  void revokeAllForUser(TenantId tenantId, UserId userId) {
    revokeAll(findByUser(tenantId, userId));
  }

  void revokeAllForSession(TenantId tenantId, SessionId sessionId) {
    revokeAll(findBySession(tenantId, sessionId));
  }

  size_t removeExpired(TenantId tenantId, long now) {
    auto expired = findByTenant(tenantId).filter!(t => t.isExpired(now)).array;
    if (expired.length)
      _store.remove(expired); // one snapshot write
    return expired.length;
  }

  /// Revoke in one batched store write instead of one write per token.
  protected void revokeAll(Token[] tokens) {
    Token[] changed;
    foreach (t; tokens)
      if (!t.revoked) {
        t.revoked = true;
        changed ~= t;
      }
    if (changed.length)
      _store.update(changed); // one snapshot write
  }
}
///
unittest {
  assert(tenantRepositoryTest(new TokenRepository()));

  auto repo = new TokenRepository();
  auto t = TenantId("t1");
  auto tok = Token(t);
  tok.tokenHash = "abc";
  tok.sessionId = SessionId("s1");
  repo.save(tok);
  assert(repo.findByHash(t, "abc").id == tok.id);
  assert(repo.findByHash(t, "").isNull);
  repo.revokeAllForSession(t, SessionId("s1"));
  assert(repo.findById(t, tok.id).revoked);
}
