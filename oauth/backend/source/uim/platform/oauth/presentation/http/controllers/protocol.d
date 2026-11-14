/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OAuth 2.0 protocol endpoints (application/x-www-form-urlencoded in, JSON out):
///
///   GET|POST <oauthPath>/authorize    RFC 6749 §4.1.1 + PKCE (RFC 7636) → 302 redirect_uri?code=&state=&iss=
///   POST     <oauthPath>/token        RFC 6749 §3.2 (client_credentials, authorization_code, refresh_token)
///   POST     <oauthPath>/introspect   RFC 7662 (confidential clients)
///   POST     <oauthPath>/revoke       RFC 7009
///   GET      <oauthPath>/branding     login page branding (?client_id=)
///   GET      /.well-known/oauth-authorization-server   RFC 8414 metadata
///
/// Client authentication: HTTP Basic (client_secret_basic) or client_id /
/// client_secret in the body (client_secret_post); public clients send
/// client_id only. The tenant is taken from the user token (zid), the
/// X-Tenant-Id header or the default tenant. The resource owner of
/// /authorize is the authenticated user (approuter / XSUAA token, or
/// X-User-Id when trustUserHeader is enabled for local development).
module uim.platform.oauth.presentation.http.controllers.protocol;

import std.base64 : Base64;
import std.uri : decodeComponent, encodeComponent;
import vibe.http.common : HTTPMethod;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Credentials presented by a client.
struct ClientAuth {
  string id;
  string secret;
  bool basic; /// sent via the Authorization header
}

/// application/x-www-form-urlencoded component → text.
string formDecode(string value) @trusted {
  return decodeComponent(value.replace("+", " "));
}

/// uri + query parameters (empty values are skipped).
string withQuery(string uri, string[2][] params) @trusted {
  string query;
  foreach (p; params)
    if (p[1].length > 0)
      query ~= (query.length ? "&" : "") ~ p[0] ~ "=" ~ encodeComponent(p[1]);
  if (query.length == 0)
    return uri;
  return uri ~ (uri.canFind('?') ? "&" : "?") ~ query;
}

/// Parse an "Authorization: Basic ..." header (RFC 6749 §2.3.1: id and secret are form-urlencoded).
ClientAuth parseBasicAuth(string header) @trusted {
  ClientAuth a;
  if (header.length < 6 || header[0 .. 6].toLower != "basic ")
    return a;
  string decoded;
  try
    decoded = cast(string) Base64.decode(header[6 .. $].strip);
  catch (Exception)
    protocolError(OAuthError.invalidClient, "Malformed Basic credentials");
  auto colon = decoded.indexOf(':');
  if (colon < 0)
    protocolError(OAuthError.invalidClient, "Malformed Basic credentials");
  a.id = formDecode(decoded[0 .. colon]);
  a.secret = formDecode(decoded[colon + 1 .. $]);
  a.basic = true;
  return a;
}

/// RFC 6749 §5.1 response.
Json tokenResponseJson(const TokenResponse t) {
  auto j = Json.emptyObject;
  j["access_token"] = t.accessToken;
  j["token_type"] = t.tokenType;
  j["expires_in"] = t.expiresIn;
  if (t.refreshToken.length > 0)
    j["refresh_token"] = t.refreshToken;
  j["scope"] = joinScopes(t.scopes);
  j["jti"] = t.record.id.value;
  return j;
}

/// RFC 7662 §2.2 response (an inactive token reveals nothing else).
Json introspectionJson(const IntrospectionResult r, string issuer) {
  auto j = Json.emptyObject;
  j["active"] = r.active;
  if (!r.active)
    return j;
  j["scope"] = joinScopes(r.scopes);
  j["client_id"] = r.clientId;
  j["token_type"] = r.tokenType == "access_token" ? "Bearer" : r.tokenType;
  j["sub"] = r.userId.length > 0 ? r.userId : r.clientId;
  if (r.userId.length > 0)
    j["username"] = r.userId;
  j["iat"] = unixSecondsOf(r.issuedAt);
  j["exp"] = unixSecondsOf(r.expiresAt);
  j["jti"] = r.jti;
  j["iss"] = issuer;
  j["zid"] = r.tenantId;
  return j;
}

Json protocolErrorJson(string error, string description) {
  auto j = Json.emptyObject;
  j["error"] = error;
  j["error_description"] = description;
  return j;
}

class OAuthProtocolController {
  protected OAuthPorts ports;
  protected SecuritySetup security;
  protected string issuer;
  protected string base;
  protected bool trustUserHeader;

  this(OAuthPorts ports, SecuritySetup security, const OAuthConfig config) {
    this.ports = ports;
    this.security = security;
    this.issuer = config.issuer;
    this.base = "/" ~ config.oauthPath.strip("/");
    this.trustUserHeader = config.trustUserHeader;
  }

  void registerRoutes(URLRouter router) {
    router.get(base ~ "/authorize", &authorize);
    router.post(base ~ "/authorize", &authorize);
    router.post(base ~ "/token", &token);
    router.post(base ~ "/introspect", &introspect);
    router.post(base ~ "/revoke", &revoke);
    router.get(base ~ "/branding", &branding);
    router.get("/.well-known/oauth-authorization-server", &metadata);
    router.get(base ~ "/.well-known/oauth-authorization-server", &metadata);
  }

  // ── /authorize ──────────────────────────────────────────────────────────
  void authorize(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto post = req.method == HTTPMethod.POST;
    string param(string name) {
      return post ? req.form.get(name, "") : req.query.get(name, "");
    }

    AuthorizeRequest r;
    string redirectUri;
    try {
      auto ctx = security.resolve(req, "oauth");
      r.tenantId = TenantId(ctx.tenantId);
      // the resource owner must come from a verified user token (approuter /
      // XSUAA); X-User-Id is accepted only with trustUserHeader (development)
      r.userId = ctx.authenticated || trustUserHeader ? ctx.userId : "";
      r.responseType = param("response_type");
      r.clientId = param("client_id");
      r.redirectUri = param("redirect_uri");
      r.scope_ = param("scope");
      r.state = param("state");
      r.codeChallenge = param("code_challenge");
      r.codeChallengeMethod = param("code_challenge_method");
      redirectUri = ports.authorization.redirectUriFor(r);
    } catch (OAuthException e) { // never redirect to an unverified URI
      noStore(res);
      res.writeJsonBody(protocolErrorJson(cast(string) OAuthError.invalidRequest, e.msg), 400);
      return;
    } catch (Exception e) {
      serverError(res, req, e);
      return;
    }

    string[2][] answer;
    try {
      auto grant = ports.authorization.authorize(r);
      answer = [["code", grant.code], ["state", grant.state], ["iss", issuer]];
      logServiceEvent("info", "authorization code issued", Json([
          "tenant": Json(r.tenantId.value), "client": Json(r.clientId), "user": Json(r.userId)
        ]));
    } catch (OAuthProtocolException e) {
      answer = [["error", cast(string) e.error], ["error_description", e.msg], ["state", r.state], ["iss", issuer]];
    } catch (Exception e) {
      answer = [["error", cast(string) OAuthError.serverError], ["state", r.state], ["iss", issuer]];
      logServiceEvent("error", "authorize failed", Json(["error": Json(e.msg)]));
    }
    noStore(res);
    res.redirect(withQuery(redirectUri, answer), 302);
  }

  // ── /token ──────────────────────────────────────────────────────────────
  void token(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    bool basic;
    try {
      auto ctx = security.resolve(req, "oauth");
      auto auth = clientAuthOf(req);
      basic = auth.basic;
      TokenRequest r;
      r.tenantId = TenantId(ctx.tenantId);
      r.grantType = req.form.get("grant_type", "");
      r.clientId = auth.id;
      r.clientSecret = auth.secret;
      r.scope_ = req.form.get("scope", "");
      r.code = req.form.get("code", "");
      r.redirectUri = req.form.get("redirect_uri", "");
      r.codeVerifier = req.form.get("code_verifier", "");
      r.refreshToken = req.form.get("refresh_token", "");
      auto t = ports.issuer.exchange(r);
      logServiceEvent("info", "token issued", Json([
          "tenant": Json(r.tenantId.value), "client": Json(r.clientId), "grant": Json(r.grantType),
          "jti": Json(t.record.id.value)
        ]));
      noStore(res);
      res.writeJsonBody(tokenResponseJson(t), 200);
    } catch (OAuthProtocolException e) {
      protocolFailure(res, e, basic);
    } catch (OAuthException e) {
      protocolFailure(res, new OAuthProtocolException(OAuthError.invalidRequest, e.msg), basic);
    } catch (Exception e) {
      serverError(res, req, e);
    }
  }

  // ── /introspect ─────────────────────────────────────────────────────────
  void introspect(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    bool basic;
    try {
      auto tenant = TenantId(security.resolve(req, "oauth").tenantId);
      auto auth = clientAuthOf(req);
      basic = auth.basic;
      auto client = ports.authentication.authenticate(tenant, auth.id, auth.secret);
      if (!client.isConfidential)
        protocolError(OAuthError.invalidClient, "Introspection requires a confidential client");
      auto token = req.form.get("token", "");
      if (token.length == 0)
        protocolError(OAuthError.invalidRequest, "token is required");
      auto r = ports.introspection.introspect(tenant, token, req.form.get("token_type_hint", ""));
      noStore(res);
      res.writeJsonBody(introspectionJson(r, issuer), 200);
    } catch (OAuthProtocolException e) {
      protocolFailure(res, e, basic);
    } catch (Exception e) {
      serverError(res, req, e);
    }
  }

  // ── /revoke ─────────────────────────────────────────────────────────────
  void revoke(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    bool basic;
    try {
      auto tenant = TenantId(security.resolve(req, "oauth").tenantId);
      auto auth = clientAuthOf(req);
      basic = auth.basic;
      auto client = ports.authentication.authenticate(tenant, auth.id, auth.secret);
      auto token = req.form.get("token", "");
      if (token.length == 0)
        protocolError(OAuthError.invalidRequest, "token is required");
      auto r = ports.introspection.revoke(tenant, token, req.form.get("token_type_hint", ""), client.clientId);
      if (r.total > 0)
        logServiceEvent("info", "token revoked", Json([
            "tenant": Json(tenant.value), "client": Json(client.clientId), "accessTokens": Json(r.accessTokens),
            "refreshTokens": Json(r.refreshTokens)
          ]));
      noStore(res);
      res.statusCode = 200; // also for unknown tokens (RFC 7009 §2.2)
      res.writeBody("");
    } catch (OAuthProtocolException e) {
      protocolFailure(res, e, basic);
    } catch (Exception e) {
      serverError(res, req, e);
    }
  }

  // ── /branding ───────────────────────────────────────────────────────────
  void branding(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto tenant = TenantId(security.resolve(req, "oauth").tenantId);
      auto b = ports.brandings.brandingFor(tenant, req.query.get("client_id", ""));
      if (b.isNull) {
        res.writeJsonBody(protocolErrorJson("not_found", "No branding configured"), 404);
        return;
      }
      auto j = Json.emptyObject;
      static foreach (f; ["name", "logoUrl", "backgroundUrl", "primaryColor", "secondaryColor", "pageTitle", "footerText", "customCss"])
        j[f] = __traits(getMember, b, f);
      res.headers["Cache-Control"] = "public, max-age=300";
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      serverError(res, req, e);
    }
  }

  // ── RFC 8414 metadata ───────────────────────────────────────────────────
  void metadata(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto tenant = TenantId(security.resolve(req, "oauth").tenantId);
      auto endpoint = (string path) => Json(issuer ~ base ~ path);
      auto j = Json.emptyObject;
      j["issuer"] = issuer;
      j["authorization_endpoint"] = endpoint("/authorize");
      j["token_endpoint"] = endpoint("/token");
      j["introspection_endpoint"] = endpoint("/introspect");
      j["revocation_endpoint"] = endpoint("/revoke");
      j["response_types_supported"] = Json([Json("code")]);
      j["response_modes_supported"] = Json([Json("query")]);
      j["grant_types_supported"] = textsJson(domainEnumValues!GrantType);
      j["token_endpoint_auth_methods_supported"] = Json([Json("client_secret_basic"), Json("client_secret_post"), Json("none")]);
      j["introspection_endpoint_auth_methods_supported"] = Json([Json("client_secret_basic"), Json("client_secret_post")]);
      j["revocation_endpoint_auth_methods_supported"] = Json([Json("client_secret_basic"), Json("client_secret_post"), Json("none")]);
      j["code_challenge_methods_supported"] = Json([Json("S256"), Json("plain")]);
      j["authorization_response_iss_parameter_supported"] = true;
      string[] scopes;
      foreach (s; ports.scopes.listScopes(tenant))
        if (s.isActive)
          scopes ~= s.name;
      j["scopes_supported"] = textsJson(scopes);
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      serverError(res, req, e);
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────
  protected static ClientAuth clientAuthOf(HTTPServerRequest req) @trusted {
    auto fromHeader = parseBasicAuth(req.headers.get("Authorization", ""));
    auto formId = req.form.get("client_id", "");
    auto formSecret = req.form.get("client_secret", "");
    if (!fromHeader.basic)
      return ClientAuth(formId, formSecret, false);
    if (formSecret.length > 0)
      protocolError(OAuthError.invalidRequest, "Use only one client authentication method");
    if (formId.length > 0 && formId != fromHeader.id)
      protocolError(OAuthError.invalidRequest, "client_id does not match the Basic credentials");
    return fromHeader;
  }

  protected static void noStore(HTTPServerResponse res) @trusted {
    res.headers["Cache-Control"] = "no-store";
    res.headers["Pragma"] = "no-cache";
  }

  protected static void protocolFailure(HTTPServerResponse res, OAuthProtocolException e, bool basic) @trusted {
    noStore(res);
    if (e.error == OAuthError.invalidClient && basic)
      res.headers["WWW-Authenticate"] = `Basic realm="uim-oauth"`;
    res.writeJsonBody(protocolErrorJson(cast(string) e.error, e.msg), e.httpStatus);
  }

  protected static void serverError(HTTPServerResponse res, HTTPServerRequest req, Exception e) @trusted {
    logServiceEvent("error", "unhandled OAuth error", Json(["path": Json(req.requestPath.toString), "error": Json(e.msg)]));
    noStore(res);
    res.writeJsonBody(protocolErrorJson(cast(string) OAuthError.serverError, "Internal error"), 500);
  }
}

///
unittest {
  assert(withQuery("https://a.example.com/cb", [["code", "x y"], ["state", ""]]) == "https://a.example.com/cb?code=x%20y");
  assert(withQuery("https://a.example.com/cb?k=1", [["code", "c"]]) == "https://a.example.com/cb?k=1&code=c");
  auto basic = parseBasicAuth("Basic " ~ (() @trusted => cast(string) Base64.encode(cast(const(ubyte)[]) "my%20app:s%3Acret"))());
  assert(basic.basic && basic.id == "my app" && basic.secret == "s:cret");
  assert(!parseBasicAuth("Bearer x").basic);
  assert(failsWithProtocol(OAuthError.invalidClient, () { parseBasicAuth("Basic !!!"); }));
  IntrospectionResult inactive;
  assert(introspectionJson(inactive, "https://i").length == 1);
}
