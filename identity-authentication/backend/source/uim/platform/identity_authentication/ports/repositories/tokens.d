/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.repositories.tokens;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: token persistence (tokens are stored by hash).
interface ITokenRepository : ITenantRepository!(Token, TokenId) {
  bool existsByHash(TenantId tenantId, string tokenHash);
  Token findByHash(TenantId tenantId, string tokenHash);

  Token[] findByUser(TenantId tenantId, UserId userId);
  Token[] findBySession(TenantId tenantId, SessionId sessionId);

  void revoke(TenantId tenantId, TokenId id);
  void revokeAllForUser(TenantId tenantId, UserId userId);
  void revokeAllForSession(TenantId tenantId, SessionId sessionId);
  /// Remove tokens that expired before `now`. Returns the number removed.
  size_t removeExpired(TenantId tenantId, long now);
}
