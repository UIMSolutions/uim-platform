/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for sessions:
///   GET {api}/sessions[?active=true&user=]   GET/DELETE {api}/sessions/:id   POST {api}/sessions/purge
module uim.platform.identity_authentication.presentation.http.controllers.sessions;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class SessionController : IdentityHttpController {
  protected IManageSessionsUseCase sessions;

  this(IManageSessionsUseCase sessions, string apiPath = "/api/v1", string defaultTenant = "default",
      ITokenService verifier = null) {
    super(apiPath, "sessions", defaultTenant, verifier);
    this.sessions = sessions;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/purge", &purge);
    router.get(basePath, &list);
    router.get(basePath ~ "/:id", &get);
    router.delete_(basePath ~ "/:id", &revoke);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto t = identity(req).tenantId;
      auto user = query(req, "user");
      auto items = user.length ? sessions.listByUser(t, UserId(user))
        : query(req, "active") == "true" ? sessions.listActiveSessions(t) : sessions.listSessions(t);
      replyList(res, items, "Sessions");
    });
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, sessions.getSession(identity(req).tenantId, SessionId(id)), "Session", id);
    });
  }

  void revoke(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, sessions.revokeSession(identity(req).tenantId, SessionId(param(req, "id")))));
  }

  void purge(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, sessions.purgeExpired(identity(req).tenantId)));
  }
}
