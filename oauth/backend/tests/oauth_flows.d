/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): protocol flows through
/// the ports, management through the OData engine, persistence in a file store.
module tests.oauth_flows;

import uim.platform.oauth;
import uim.platform.service.infrastructure.security.context : Hs256TokenVerifier, resolveRequestContext;

@safe:

version (unittest) {
  enum string testSecret = "integration-test-signing-secret-0123456789";

  OAuthContainer newContainer(IDocumentStore store = null) {
    Json[string] o;
    o["storage"] = "memory";
    o["signingSecret"] = testSecret;
    o["issuer"] = "https://oauth.example.com";
    return new OAuthContainer(loadOAuthConfig(o, "/nonexistent"), store);
  }

  RequestContext admin(string tenant = "t1") {
    return RequestContext.local(tenant, "test", "admin");
  }

  int statusOf(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }

  /// A confidential web client (code + refresh) with two scopes; returns its secret.
  string setUpWebClient(OAuthContainer c, string tenant = "t1") {
    foreach (s; ["orders.read", "orders.write"])
      c.engine.create(admin(tenant), "OAuthScopes", Json(["applicationId": Json("orders"), "name": Json(s)]));
    CreateClientRequest r; // via the port: OData generates the key itself
    r.tenantId = TenantId(tenant);
    r.actor = UserId("admin");
    r.id = "portal";
    r.clientId = "portal";
    r.name = "Portal";
    r.grantTypes = ["authorization_code", "refresh_token"];
    r.redirectUris = ["https://portal.example.com/cb"];
    r.allowedScopes = ["orders.read", "orders.write"];
    return c.ports.clients.createClient(r).clientSecret;
  }

  TokenResponse codeFlow(OAuthContainer c, string secret, string scope_ = "", string tenant = "t1") {
    AuthorizeRequest a;
    a.tenantId = TenantId(tenant);
    a.userId = "jane";
    a.responseType = "code";
    a.clientId = "portal";
    a.scope_ = scope_;
    auto grant = c.ports.authorization.authorize(a);
    TokenRequest t;
    t.tenantId = TenantId(tenant);
    t.grantType = "authorization_code";
    t.clientId = "portal";
    t.clientSecret = secret;
    t.code = grant.code;
    return c.ports.issuer.exchange(t);
  }

  TokenResponse refreshWith(OAuthContainer c, string secret, string refreshToken, string scope_ = "") {
    TokenRequest t;
    t.tenantId = TenantId("t1");
    t.grantType = "refresh_token";
    t.clientId = "portal";
    t.clientSecret = secret;
    t.refreshToken = refreshToken;
    t.scope_ = scope_;
    return c.ports.issuer.exchange(t);
  }
}

/// Secrets are generated, shown once and stored only as hashes.
unittest {
  auto c = newContainer();
  auto secret = setUpWebClient(c);
  assert(secret.length >= 43);
  auto created = c.engine.create(admin, "OAuthClients", parseJsonString(`{"name":"Job","allowedScopes":["orders.read"]}`));
  assert(created["clientSecret"].get!string.length >= 43 && created["clientId"].get!string.startsWith("sb-"));
  assert(created["grantTypes"][0].get!string == "client_credentials");
  auto row = c.engine.read(admin, "OAuthClients", "portal");
  assert(row["clientSecret"].type == Json.Type.null_ && row["hasSecret"].get!bool);
  auto stored = c.store.get(Collections.clients, "t1", "portal");
  assert(stored["secretHash"].get!string != secret && !stored.toString.canFind(secret));
}

/// Refresh token rotation: the old token is retired, a replay revokes the whole grant.
unittest {
  auto c = newContainer();
  auto secret = setUpWebClient(c);
  auto first = codeFlow(c, secret);
  assert(first.refreshToken.length > 0 && first.scopes == ["orders.read", "orders.write"]);

  auto second = refreshWith(c, secret, first.refreshToken, "orders.read"); // narrowing is allowed
  assert(second.scopes == ["orders.read"] && second.refreshToken != first.refreshToken);
  assert(failsWithProtocol(OAuthError.invalidScope, () { refreshWith(c, secret, second.refreshToken, "billing.read"); }));

  // replay of the rotated token → invalid_grant and everything of the grant is revoked
  assert(failsWithProtocol(OAuthError.invalidGrant, () { refreshWith(c, secret, first.refreshToken); }));
  auto introspection = c.ports.introspection;
  assert(!introspection.introspect(TenantId("t1"), second.accessToken).active);
  assert(!introspection.introspect(TenantId("t1"), second.refreshToken, "refresh_token").active);
  assert(failsWithProtocol(OAuthError.invalidGrant, () { refreshWith(c, secret, second.refreshToken); }));
}

/// Blocking a client revokes its tokens and stops authentication.
unittest {
  auto c = newContainer();
  auto secret = setUpWebClient(c);
  auto t = codeFlow(c, secret);
  c.engine.update(admin, "OAuthClients", "portal", parseJsonString(`{"status":"blocked"}`));
  assert(c.ports.tokens.getAccessToken(TenantId("t1"), t.record.id).status == TokenStatus.revoked);
  assert(failsWithProtocol(OAuthError.invalidClient, () { refreshWith(c, secret, t.refreshToken); }));
  auto stats = c.engine.read(admin, "Statistics", "");
  assert(stats["blockedClients"].get!long == 1 && stats["revokedAccessTokens"].get!long == 1);
}

/// Redirect URI validation happens before anything is redirected.
unittest {
  auto c = newContainer();
  setUpWebClient(c);
  AuthorizeRequest a;
  a.tenantId = TenantId("t1");
  a.clientId = "portal";
  a.responseType = "code";
  a.redirectUri = "https://evil.example.com/cb";
  assert(failsWith(OAuthErrorKind.invalid, () { c.ports.authorization.redirectUriFor(a); }));
  a.redirectUri = "";
  assert(c.ports.authorization.redirectUriFor(a) == "https://portal.example.com/cb");
  assert(failsWithProtocol(OAuthError.loginRequired, () { c.ports.authorization.authorize(a); }));
  a.userId = "jane";
  a.responseType = "token";
  assert(failsWithProtocol(OAuthError.unsupportedResponseType, () { c.ports.authorization.authorize(a); }));
}

/// Issued tokens are platform tokens: resolveRequestContext of uim-platform:service accepts them.
unittest {
  auto c = newContainer();
  auto secret = setUpWebClient(c);
  auto t = codeFlow(c, secret, "orders.read");
  auto ctx = resolveRequestContext("Bearer " ~ t.accessToken, "", "", "default", new Hs256TokenVerifier(testSecret));
  assert(ctx.authenticated && ctx.tenantId == "t1" && ctx.userId == "jane" && ctx.hasScope("orders.read"));
  assert(!ctx.hasScope("orders.write"));
}

/// Tenants are isolated.
unittest {
  auto c = newContainer();
  auto secret = setUpWebClient(c, "t1");
  auto t = codeFlow(c, secret);
  assert(!c.ports.introspection.introspect(TenantId("t2"), t.accessToken).active);
  assert(statusOf(() { c.engine.read(admin("t2"), "OAuthClients", "portal"); }) == 404);
  TokenRequest r;
  r.tenantId = TenantId("t2");
  r.grantType = "refresh_token";
  r.clientId = "portal";
  r.clientSecret = secret;
  r.refreshToken = t.refreshToken;
  assert(failsWithProtocol(OAuthError.invalidClient, () { c.ports.issuer.exchange(r); }));
}

/// Management rules via OData: references, uniqueness, write-only and read-only sets.
unittest {
  auto c = newContainer();
  setUpWebClient(c);
  assert(statusOf(() { c.engine.create(admin, "OAuthClients", parseJsonString(`{"name":"X","allowedScopes":["nope"]}`)); }) == 400);
  assert(statusOf(() { c.engine.create(admin, "OAuthClients", parseJsonString(`{"name":"Dup","clientId":"portal"}`)); }) == 409);
  assert(statusOf(() { c.engine.create(admin, "OAuthClients", parseJsonString(`{"name":"P","clientType":"public","grantTypes":["client_credentials"]}`)); }) == 422);
  assert(statusOf(() { c.engine.create(admin, "AccessTokens", Json.emptyObject); }) == 405);
  assert(statusOf(() { c.engine.remove(admin, "OAuthScopes", c.engine.query(admin, "OAuthScopes", ["$filter": "name eq 'orders.read'"]).rows[0]["id"].get!string); }) == 422);

  // the first branding becomes the default; a second default replaces it
  auto a = c.engine.create(admin, "BrandingConfigs", parseJsonString(`{"name":"A"}`))["id"].get!string;
  assert(c.engine.read(admin, "BrandingConfigs", a)["isDefault"].get!bool); // first one
  auto b = c.engine.create(admin, "BrandingConfigs", parseJsonString(`{"name":"B","isDefault":true,"primaryColor":"#123456"}`))["id"].get!string;
  assert(!c.engine.read(admin, "BrandingConfigs", a)["isDefault"].get!bool);
  assert(c.ports.brandings.brandingFor(TenantId("t1"), "portal").id.value == b);
  // a client may use its own branding
  c.engine.update(admin, "OAuthClients", "portal", Json(["brandingId": Json(a)]));
  assert(c.ports.brandings.brandingFor(TenantId("t1"), "portal").id.value == a);
  assert(statusOf(() { c.engine.remove(admin, "BrandingConfigs", a); }) == 422); // still used
  assert(statusOf(() { c.engine.create(admin, "BrandingConfigs", parseJsonString(`{"name":"C","customCss":"</style>"}`)); }) == 400);

  auto rotated = c.engine.invoke(admin, "RotateClientSecret", Json(["id": Json("portal")]));
  assert(rotated["clientSecret"].get!string.length >= 43);
}

/// File store: server, CLI and GUI share data and the generated signing key; purge cleans up.
unittest {
  import std.file : exists, remove, tempDir;
  import std.path : buildPath;

  auto path = buildPath(tempDir, "uim-oauth-test-" ~ newResourceId() ~ ".json");
  scope (exit)
    if (exists(path))
      remove(path);
  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = path;
  auto server = new OAuthContainer(loadOAuthConfig(o, "/nonexistent"));
  auto secret = setUpWebClient(server);
  auto t = codeFlow(server, secret);

  auto cli = new OAuthContainer(loadOAuthConfig(o, "/nonexistent")); // second process view
  assert(server.signingKey.source == "generated" && cli.signingKey.source == "store");
  assert(cli.signingKey.secret == server.signingKey.secret);
  assert(cli.ports.introspection.introspect(TenantId("t1"), t.accessToken).active);

  cli.ports.introspection.revoke(TenantId("t1"), t.refreshToken, "refresh_token", "portal");
  assert(!server.ports.introspection.introspect(TenantId("t1"), t.accessToken).active); // parent revoked
  auto purged = server.ports.tokens.purgeExpired(TenantId("t1"));
  assert(purged.accessTokens == 1 && purged.refreshTokens == 1, purged.to!string);
}
