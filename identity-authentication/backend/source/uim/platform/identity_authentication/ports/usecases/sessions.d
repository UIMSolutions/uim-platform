/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.sessions;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: session administration.
interface IManageSessionsUseCase {
  IASession[] listSessions(TenantId tenantId);
  IASession[] listActiveSessions(TenantId tenantId);
  IASession[] listByUser(TenantId tenantId, UserId userId);
  IASession getSession(TenantId tenantId, SessionId id);
  /// Revoke a session and its tokens.
  UsecaseResult revokeSession(TenantId tenantId, SessionId id);
  UsecaseResult revokeAllForUser(TenantId tenantId, UserId userId);
  UsecaseResult purgeExpired(TenantId tenantId);
}
