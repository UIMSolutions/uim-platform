/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.sessions;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Session administration (list, revoke, purge).
class ManageSessionsUseCase : IManageSessionsUseCase {
  protected ISessionRepository repo;
  protected ITokenRepository tokens;
  protected IIdentityEventPublisher events;

  this(ISessionRepository repo, ITokenRepository tokens = null, IIdentityEventPublisher events = null) {
    this.repo = repo;
    this.tokens = tokens;
    this.events = events is null ? new NullEventPublisher : events;
  }

  IASession[] listSessions(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  IASession[] listActiveSessions(TenantId tenantId) {
    auto now = nowStdTime();
    return repo.findByTenant(tenantId).filter!(s => s.isActive(now)).array;
  }

  IASession[] listByUser(TenantId tenantId, UserId userId) {
    return repo.findByUser(tenantId, userId);
  }

  IASession getSession(TenantId tenantId, SessionId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult revokeSession(TenantId tenantId, SessionId id) {
    auto session = repo.findById(tenantId, id);
    if (session.isNull)
      return notFound("Session", id.value);
    repo.revoke(tenantId, id);
    if (tokens !is null)
      tokens.revokeAllForSession(tenantId, id);
    events.publish(IdentityTopics.sessionRevoked, Json.emptyObject
        .set("tenantId", tenantId.value).set("sessionId", id.value).set("userId", session.userId.value));
    return succeeded(id.value, "Session revoked");
  }

  UsecaseResult revokeAllForUser(TenantId tenantId, UserId userId) {
    repo.revokeAllForUser(tenantId, userId);
    if (tokens !is null)
      tokens.revokeAllForUser(tenantId, userId);
    return succeeded(userId.value, "All sessions of the user revoked");
  }

  UsecaseResult purgeExpired(TenantId tenantId) {
    auto removed = repo.removeExpired(tenantId, nowStdTime());
    return succeeded("", removed.to!string ~ " expired session(s) removed", 200,
      Json.emptyObject.set("removed", removed));
  }
}

///
unittest {
  mixin(ShowTest!("ManageSessionsUseCase"));

  auto repo = new SessionRepository();
  auto tokens = new TokenRepository();
  auto uc = new ManageSessionsUseCase(repo, tokens);
  auto t = TenantId("t1");

  auto live = IASession(t);
  live.userId = UserId("u1");
  live.expiresAt = nowStdTime() + hnsecsPerMinute;
  repo.save(live);
  auto old = IASession(t);
  old.expiresAt = 1;
  repo.save(old);

  auto token = Token(t);
  token.sessionId = live.id;
  tokens.save(token);

  assert(uc.listSessions(t).length == 2);
  assert(uc.listActiveSessions(t).length == 1);
  assert(uc.revokeSession(t, live.id).isSuccess);
  assert(uc.getSession(t, live.id).revoked);
  assert(tokens.findById(t, token.id).revoked);
  assert(uc.purgeExpired(t).data["removed"].get!long == 1);
  assert(uc.revokeSession(t, SessionId("nope")).code == 404);
}
