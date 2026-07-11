/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.repositories.tokens;
// import uim.platform.identity_authentication.domain.entities.token;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.token;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for token persistence.
class MemoryTokenRepository : TenantRepository!(Token, TokenId), TokenRepository {

  bool existsByValue(TenantId tenantId, string tokenValue) {
    return findByTenant(tenantId).any!(t => t.tokenValue == tokenValue);
  }
  
  Token findByValue(TenantId tenantId, string tokenValue) {
    foreach (t; findByTenant(tenantId)) {
      if (t.tokenValue == tokenValue)
        return t;
    }
    return Token.init;
  }

  Token[] findByUser(TenantId tenantId, UserId userId) {
    Token[] result;
    foreach (t; findByTenant(tenantId)) {
      if (t.userId == userId)
        result ~= t;
    }
    return result;
  }

  void revoke(TenantId tenantId, TokenId id) {
    if (existsById(tenantId, id)) {
      auto updated = findById(tenantId, id);
      updated.revoked = true;
      update(updated);
    }
  }

  void revokeAllForUser(TenantId tenantId, UserId userId) {
    foreach (t; findByTenant(tenantId)) {
      if (t.userId == userId) {
        auto updated = t;
        updated.revoked = true;
        update(updated);
      }
    }
  }
}
