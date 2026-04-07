/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.token_repo;

// import uim.platform.identity_authentication.domain.entities.token;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.token;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for token persistence.
class MemoryTokenRepository : TokenRepository {
  private Token[TokenId] store;

  Token findById(TokenId id) {
    if (auto p = id in store)
      return *p;
    return Token.init;
  }

  Token findByValue(string tokenValue) {
    foreach (t; store.byValue()) {
      if (t.tokenValue == tokenValue)
        return t;
    }
    return Token.init;
  }

  Token[] findByUser(UserId userId) {
    Token[] result;
    foreach (t; store.byValue()) {
      if (t.userId == userId)
        result ~= t;
    }
    return result;
  }

  void save(Token token) {
    store[token.id] = token;
  }

  void revoke(TokenId id) {
    if (auto p = id in store) {
      p.revoked = true;
      store[id] = *p;
    }
  }

  void revokeAllForUser(UserId userId) {
    foreach (ref t; store.byValue()) {
      if (t.userId == userId) {
        auto updated = t;
        updated.revoked = true;
        store[t.id] = updated;
      }
    }
  }
}
