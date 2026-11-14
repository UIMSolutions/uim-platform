/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authentication endpoints (login, OAuth 2.0 token / refresh, introspection,
/// revocation, OIDC userinfo and discovery).
///
///   POST {api}/auth/login        {"email"|"userName", "password", "mfaCode"?}
///   POST {api}/auth/logout       {"sessionId"}
///   POST {api}/auth/token        grant_type=session|refresh_token (JSON or form, Basic client auth)
///   POST {api}/auth/refresh      {"refreshToken", "clientId", "clientSecret"}
///   POST {api}/auth/introspect   {"token"}                     (RFC 7662)
///   POST {api}/auth/revoke       {"token"}                     (RFC 7009)
///   GET  {api}/auth/userinfo     Authorization: Bearer <access token>
///   GET  /.well-known/openid-configuration
module uim.platform.identity_authentication.presentation.http.controllers.auth;

import std.base64 : Base64;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class AuthController : IdentityHttpController {
  protected IAuthenticationUseCase authentication;
  protected ITokenUseCase tokens;
  protected string issuer;

  this(IAuthenticationUseCase authentication, ITokenUseCase tokens, string apiPath, string defaultTenant,
      string issuer, ITokenService verifier = null) {
    super(apiPath, "auth", defaultTenant, verifier);
    this.authentication = authentication;
    this.tokens = tokens;
    this.issuer = issuer;
  }

  override void registerRoutes(URLRouter router) {
    router.post(basePath ~ "/login", &login);
    router.post(basePath ~ "/logout", &logout);
    router.post(basePath ~ "/token", &token);
    router.post(basePath ~ "/refresh", &refresh);
    router.post(basePath ~ "/introspect", &introspect);
    router.post(basePath ~ "/revoke", &revoke);
    router.get(basePath ~ "/userinfo", &userInfo);
    router.get("/.well-known/openid-configuration", &discovery);
  }

  void login(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      AuthRequest auth;
      readPayload(auth, body(req));
      auth.tenantId = identity(req).tenantId;
      auth.ipAddress = clientAddress(req);
      auth.userAgent = req.headers.get("User-Agent", "");
      auto result = authentication.login(auth);
      res.writeJsonBody(result.toJson, result.success ? 200 : result.code);
    });
  }

  void logout(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto session = stringOf(body(req), "sessionId");
      if (session.length == 0)
        return fail(res, 400, "sessionId is required");
      replyResult(res, authentication.logout(identity(req).tenantId, SessionId(session)));
    });
  }

  /// OAuth token endpoint: grant_type "session" (default) or "refresh_token".
  void token(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto params = tokenParameters(req);
      auto tenant = identity(req).tenantId;
      TokenResponse r;
      if (stringOf(params, "grant_type") == "refresh_token") {
        RefreshRequest rr;
        readPayload(rr, params);
        rr.tenantId = tenant;
        r = tokens.refreshTokens(rr);
      } else {
        TokenRequest tr;
        readPayload(tr, params);
        tr.tenantId = tenant;
        tr.ipAddress = clientAddress(req);
        r = tokens.issueTokens(tr);
      }
      writeToken(res, r);
    });
  }

  void refresh(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      RefreshRequest rr;
      readPayload(rr, tokenParameters(req));
      rr.tenantId = identity(req).tenantId;
      writeToken(res, tokens.refreshTokens(rr));
    });
  }

  void introspect(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto info = tokens.introspect(identity(req).tenantId, stringOf(tokenParameters(req), "token"));
      res.writeJsonBody(info.toJson, 200);
    });
  }

  void revoke(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto token = stringOf(tokenParameters(req), "token");
      if (token.length == 0)
        return fail(res, 400, "token is required");
      replyResult(res, tokens.revoke(identity(req).tenantId, token));
    });
  }

  void userInfo(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto access = bearerToken(req.headers.get("Authorization", ""));
      auto tenant = TenantId(req.headers.get("X-Tenant-Id", ""));
      if (tenant.isEmpty) {
        // the tenant is carried by the token itself
        auto claims = decodeJwtClaims(access);
        tenant = TenantId(claims.type == Json.Type.object ? fieldString(claims, "zid", defaultTenant) : defaultTenant);
      }
      auto info = tokens.userInfo(tenant, access);
      if (info.type == Json.Type.null_) {
        res.headers["WWW-Authenticate"] = `Bearer error="invalid_token"`;
        return fail(res, 401, "Access token is invalid, expired or revoked");
      }
      res.writeJsonBody(info, 200);
    });
  }

  void discovery(HTTPServerRequest req, HTTPServerResponse res) {
    auto proto = req.headers.get("X-Forwarded-Proto", req.tls ? "https" : "http");
    auto root = proto ~ "://" ~ req.headers.get("X-Forwarded-Host", req.host);
    auto api = basePath;
    res.writeJsonBody(Json.emptyObject
        .set("issuer", issuer)
        .set("token_endpoint", root ~ api ~ "/token")
        .set("userinfo_endpoint", root ~ api ~ "/userinfo")
        .set("introspection_endpoint", root ~ api ~ "/introspect")
        .set("revocation_endpoint", root ~ api ~ "/revoke")
        .set("grant_types_supported", ["session", "refresh_token"].map!(s => Json(s)).array.toJson)
        .set("token_endpoint_auth_methods_supported", ["client_secret_post", "client_secret_basic"].map!(s => Json(s)).array.toJson)
        .set("id_token_signing_alg_values_supported", [Json("HS256")].toJson)
        .set("scopes_supported", ["openid", "profile", "email"].map!(s => Json(s)).array.toJson), 200);
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// JSON body or form fields, plus HTTP Basic client credentials.
  protected Json tokenParameters(HTTPServerRequest req) {
    Json params = Json.emptyObject;
    if (req.contentType == "application/x-www-form-urlencoded") {
      foreach (k, v; req.form.byKeyValue)
        params[k] = v;
    } else
      params = body(req);

    auto basic = req.headers.get("Authorization", "");
    if (basic.length > 6 && sicmp(basic[0 .. 6], "Basic ") == 0 && !hasValue(params, "client_id")) {
      try {
        auto decoded = cast(string) Base64.decode(basic[6 .. $].strip).idup;
        auto colon = decoded.indexOf(':');
        if (colon > 0) {
          params["client_id"] = decoded[0 .. colon];
          params["client_secret"] = decoded[colon + 1 .. $];
        }
      } catch (Exception) {
        throw new PayloadException("Invalid Basic authorization header");
      }
    }
    return params;
  }

  protected static void writeToken(HTTPServerResponse res, TokenResponse r) {
    res.headers["Cache-Control"] = "no-store";
    res.headers["Pragma"] = "no-cache";
    res.writeJsonBody(r.toJson, r.isSuccess ? 200 : r.code);
  }

  /// Client address: first X-Forwarded-For entry (behind the approuter) or the peer.
  protected static string clientAddress(HTTPServerRequest req) {
    auto forwarded = req.headers.get("X-Forwarded-For", "");
    if (forwarded.length)
      return forwarded.split(",")[0].strip;
    return req.clientAddress.toAddressString;
  }
}
