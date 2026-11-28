/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Login and session endpoints of the built-in JWT authentication:
///
///   GET   /auth/config      {mode, loginRequired}                 public
///   POST  /auth/login       {username, password, tenant?}        → {access_token, token_type, expires_in, scope, user}
///                           (also application/x-www-form-urlencoded, OAuth2 password grant style)
///   GET   /auth/me          the caller (user, tenant, scopes)
///   POST  /auth/password    {currentPassword, newPassword}       change the own password
///   POST  /auth/logout      stateless: the client discards its token (204)
///
/// In xsuaa mode the approuter logs users in; /auth/login answers 404.
module uim.platform.ai_launchpad.presentation.http.controllers.auth;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class AuthController {
  protected AilpPorts ports;
  protected SecuritySetup security;
  protected string root;

  this(AilpPorts ports, SecuritySetup security, string root = "/auth") {
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ root.strip("/");
  }

  void registerRoutes(URLRouter router) {
    router.get(root ~ "/config", &config);
    router.post(root ~ "/login", &login);
    router.get(root ~ "/me", &me);
    router.post(root ~ "/password", &password);
    router.post(root ~ "/logout", &logout);
  }

  void config(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto j = Json.emptyObject;
    j["mode"] = security.mode;
    j["loginRequired"] = security.loginEnabled;
    j["loginUrl"] = security.loginEnabled ? root ~ "/login" : "";
    j["defaultTenant"] = security.defaultTenant;
    send(res, 200, j);
  }

  void login(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    if (!security.loginEnabled) {
      send(res, 404, error("404", security.mode == "xsuaa" ? "Login is handled by the approuter (XSUAA)"
          : "Authentication is disabled (authMode 'open')"));
      return;
    }
    try {
      auto text = req.bodyReader.readAllUTF8(false, 64 * 1024);
      Json body = Json.emptyObject;
      if (req.headers.get("Content-Type", "").startsWith("application/x-www-form-urlencoded")) {
        import vibe.inet.webform : FormFields, parseURLEncodedForm;

        FormFields form;
        parseURLEncodedForm(text, form);
        foreach (k; ["username", "password", "tenant"])
          if (auto v = k in form)
            body[k] = *v;
      } else if (text.strip.length)
        body = AilpApiController.parseBody(text);

      LoginRequest r;
      auto tenant = textOf(body, "tenant").strip;
      r.tenantId = TenantId(tenant.length ? tenant : req.headers.get("X-Tenant-Id", security.defaultTenant));
      r.username = textOf(body, "username");
      r.password = textOf(body, "password");
      if (r.username.strip.length == 0 || r.password.length == 0)
        throw AilpException.invalid("username and password are required");
      auto result = ports.authentication.login(r);
      auto j = Json.emptyObject;
      j["access_token"] = result.token.accessToken;
      j["token_type"] = result.token.tokenType;
      j["expires_in"] = result.token.expiresIn;
      j["scope"] = result.scopes.join(" ");
      j["user"] = userJson(result.user, r.tenantId.value, result.scopes);
      send(res, 200, j);
    } catch (AilpException e) {
      send(res, e.kind == AilpErrorKind.invalid ? 400 : 401, error(e.kind == AilpErrorKind.invalid ? "400" : "401", e.msg));
    } catch (Exception e) {
      logServiceEvent("error", "login failed", Json(["error": Json(e.msg)]));
      send(res, 500, error("500", "Internal error"));
    }
  }

  void me(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto ctx = security.resolve(req, "auth");
    if (security.requireAuthentication && !ctx.authenticated) {
      send(res, 401, error("401", "A valid bearer token is required"));
      return;
    }
    auto j = Json.emptyObject;
    j["authenticated"] = ctx.authenticated;
    j["mode"] = security.mode;
    j["user"] = ctx.actor;
    j["displayName"] = ctx.userName.length ? ctx.userName : ctx.actor;
    j["tenant"] = ctx.tenantId;
    auto scopes = Json.emptyArray;
    foreach (s; security.requireAuthentication ? ctx.scopes : knownScopes)
      scopes ~= Json(s);
    j["scopes"] = scopes;
    if (security.loginEnabled && ctx.authenticated) {
      try {
        auto u = ports.users.getUser(TenantId(ctx.tenantId), UserAccountId(ctx.actor));
        j["email"] = u.email;
        j["roles"] = texts(u.roles);
      } catch (Exception) {
      }
    }
    send(res, 200, j);
  }

  void password(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto ctx = security.resolve(req, "auth");
    if (!security.loginEnabled || !ctx.authenticated) {
      send(res, 401, error("401", "A valid bearer token of the built-in login is required"));
      return;
    }
    try {
      auto body = AilpApiController.parseBody(req.bodyReader.readAllUTF8(false, 64 * 1024));
      ChangePasswordRequest r;
      r.tenantId = TenantId(ctx.tenantId);
      r.actor = UserId(ctx.actor);
      r.currentPassword = textOf(body, "currentPassword");
      r.newPassword = textOf(body, "newPassword");
      ports.authentication.changePassword(r);
      res.statusCode = 204;
      res.writeVoidBody();
    } catch (AilpException e) {
      send(res, e.kind == AilpErrorKind.unauthorized ? 401 : 400, error(e.kind == AilpErrorKind.unauthorized ? "401" : "400", e.msg));
    }
  }

  void logout(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.statusCode = 204;
    res.writeVoidBody();
  }

  static Json userJson(const UserAccount u, string tenant, const string[] scopes) {
    auto j = Json.emptyObject;
    j["id"] = u.id.value;
    j["displayName"] = u.displayName;
    j["email"] = u.email;
    j["tenant"] = tenant;
    j["roles"] = texts(u.roles);
    j["scopes"] = texts(scopes);
    return j;
  }

  protected static Json error(string code, string message) {
    return Json(["error": Json(["code": Json(code), "message": Json(message)])]);
  }

  protected static void send(HTTPServerResponse res, int status, Json body) @trusted {
    res.headers["Cache-Control"] = "no-store";
    res.writeJsonBody(body, status);
  }
}
