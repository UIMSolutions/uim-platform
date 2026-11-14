/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.repositories.sessions;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: session persistence.
interface ISessionRepository : ITenantRepository!(IASession, SessionId) {
  IASession[] findByUser(TenantId tenantId, UserId userId);

  void revoke(TenantId tenantId, SessionId id);
  void revokeAllForUser(TenantId tenantId, UserId userId);
  /// Remove sessions that expired before `now`. Returns the number removed.
  size_t removeExpired(TenantId tenantId, long now);
}
