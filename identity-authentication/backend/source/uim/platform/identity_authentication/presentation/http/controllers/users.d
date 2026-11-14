/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST adapter for users:
///   GET/POST {api}/users[?status=&group=]   GET/PUT/PATCH/DELETE {api}/users/:id
///   POST {api}/users/:id/status {"status"}  POST {api}/users/:id/password {"oldPassword","newPassword"}
///   POST {api}/users/:id/reset-password {"newPassword"}
///   POST {api}/users/:id/mfa {"mfaType"}     DELETE {api}/users/:id/mfa
///   GET  {api}/users/:id/sessions
///   POST {api}/users/change-password {"userId","oldPassword","newPassword"}  (compatibility)
module uim.platform.identity_authentication.presentation.http.controllers.users;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class UserController : IdentityHttpController {
  protected IManageUsersUseCase users;
  protected IManageSessionsUseCase sessions;

  this(IManageUsersUseCase users, IManageSessionsUseCase sessions, string apiPath = "/api/v1",
      string defaultTenant = "default", ITokenService verifier = null) {
    super(apiPath, "users", defaultTenant, verifier);
    this.users = users;
    this.sessions = sessions;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/change-password", &changePasswordCompat);
    crudRoutes(router, &list, &get, &create, &update, &remove);
    router.post(basePath ~ "/:id/status", &setStatus);
    router.post(basePath ~ "/:id/password", &changePassword);
    router.post(basePath ~ "/:id/reset-password", &resetPassword);
    router.post(basePath ~ "/:id/mfa", &enrollMfa);
    router.delete_(basePath ~ "/:id/mfa", &disableMfa);
    router.get(basePath ~ "/:id/sessions", &listSessions);
  }

  void list(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto t = identity(req).tenantId;
      auto items = users.listUsers(t);
      UserStatus status;
      if (tryParseEnum!UserStatus(query(req, "status"), status))
        items = items.filter!(u => u.status == status).array;
      auto group = query(req, "group");
      if (group.length)
        items = items.filter!(u => u.isMemberOf(GroupId(group))).array;
      replyList(res, items, "Users");
    });
  }

  void get(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto id = param(req, "id");
      replyOne(res, users.getUser(identity(req).tenantId, UserId(id)), "User", id);
    });
  }

  void create(HTTPServerRequest req, HTTPServerResponse res) {
    createWith!UserDTO(req, res, (dto) => users.createUser(dto));
  }

  void update(HTTPServerRequest req, HTTPServerResponse res) {
    mergeWith!(UserDTO, IAUser)(req, res, "User", (t, id) => users.getUser(t, UserId(id)), (dto) {
      dto.password = ""; // passwords change via /password or /reset-password only
      return users.updateUser(dto);
    });
  }

  void remove(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyResult(res, users.deleteUser(identity(req).tenantId, UserId(param(req, "id")))));
  }

  void setStatus(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto who = identity(req);
      UserStatus status;
      if (!tryParseEnum!UserStatus(stringOf(body(req), "status"), status))
        return fail(res, 400, "status must be one of " ~ enumValues!UserStatus().join(", "));
      replyResult(res, users.setUserStatus(who.tenantId, UserId(param(req, "id")), status, who.userId));
    });
  }

  void changePassword(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto b = body(req);
      ChangePasswordRequest r;
      r.tenantId = identity(req).tenantId;
      r.userId = UserId(param(req, "id"));
      r.oldPassword = stringOf(b, "oldPassword");
      r.newPassword = stringOf(b, "newPassword");
      replyResult(res, users.changePassword(r));
    });
  }

  void changePasswordCompat(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto b = body(req);
      ChangePasswordRequest r;
      r.tenantId = identity(req).tenantId;
      r.userId = UserId(stringOf(b, "userId"));
      r.oldPassword = stringOf(b, "oldPassword");
      r.newPassword = stringOf(b, "newPassword");
      replyResult(res, users.changePassword(r));
    });
  }

  void resetPassword(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto who = identity(req);
      replyResult(res, users.resetPassword(who.tenantId, UserId(param(req, "id")),
        stringOf(body(req), "newPassword"), who.userId));
    });
  }

  void enrollMfa(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto who = identity(req);
      MfaType type;
      if (!tryParseEnum!MfaType(stringOf(body(req), "mfaType", "totp"), type))
        return fail(res, 400, "mfaType must be one of totp, sms, email");
      replyResult(res, users.enrollMfa(who.tenantId, UserId(param(req, "id")), type, who.userId));
    });
  }

  void disableMfa(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto who = identity(req);
      replyResult(res, users.disableMfa(who.tenantId, UserId(param(req, "id")), who.userId));
    });
  }

  void listSessions(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () => replyList(res, sessions.listByUser(identity(req).tenantId, UserId(param(req, "id"))), "Sessions"));
  }
}
