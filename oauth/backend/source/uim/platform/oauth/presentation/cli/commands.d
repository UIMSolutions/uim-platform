/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus OAuth specific commands.
module uim.platform.oauth.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-oauth-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildOAuthCli(OAuthContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "OAuth 2.0 administration: clients, scopes, tokens, authorization codes, brandings", output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("token", "<clientId> [--secret=S] [--grant=client_credentials|authorization_code|refresh_token] [--scope=\"a b\"] "
    ~ "[--code=C --redirect-uri=U --verifier=V] [--refresh-token=R]",
    "Call the token endpoint logic (default grant: client_credentials)", (CliContext c) {
    TokenRequest r;
    r.tenantId = TenantId(c.request.tenantId);
    r.clientId = c.operand(0, "client id");
    r.clientSecret = c.args.opt("secret");
    r.grantType = c.args.opt("grant", cast(string) GrantType.clientCredentials);
    r.scope_ = c.args.opt("scope");
    r.code = c.args.opt("code");
    r.redirectUri = c.args.opt("redirect-uri");
    r.codeVerifier = c.args.opt("verifier");
    r.refreshToken = c.args.opt("refresh-token");
    auto t = protocolCall!TokenResponse(() => ports.issuer.exchange(r));
    return c.emit(tokenResponseJson(t), TextTable.keyValue(tokenResponseJson(t),
      ["access_token", "token_type", "expires_in", "refresh_token", "scope", "jti"]));
  }, ["secret", "grant", "scope", "code", "redirect-uri", "verifier", "refresh-token"]);

  app.command("authorize", "<clientId> --user=U [--redirect-uri=U] [--scope=\"a b\"] [--challenge=C [--method=S256]] [--state=S]",
    "Issue an authorization code for a user (what /oauth/authorize does after login)", (CliContext c) {
    AuthorizeRequest r;
    r.tenantId = TenantId(c.request.tenantId);
    r.userId = c.args.requireOpt("user");
    r.responseType = "code";
    r.clientId = c.operand(0, "client id");
    r.redirectUri = c.args.opt("redirect-uri");
    r.scope_ = c.args.opt("scope");
    r.state = c.args.opt("state");
    r.codeChallenge = c.args.opt("challenge");
    r.codeChallengeMethod = c.args.opt("method", r.codeChallenge.length ? "S256" : "");
    auto g = protocolCall!AuthorizationGrant(() => ports.authorization.authorize(r));
    auto data = Json.emptyObject;
    data["code"] = g.code;
    data["redirectUri"] = g.redirectUri;
    data["redirect"] = withQuery(g.redirectUri, [["code", g.code], ["state", g.state], ["iss", config.issuer]]);
    data["expiresAt"] = isoTime(g.record.expiresAt);
    data["scope"] = joinScopes(g.record.scopes);
    return c.emit(data, TextTable.keyValue(data, ["code", "redirectUri", "scope", "expiresAt", "redirect"]));
  }, ["user", "redirect-uri", "scope", "state", "challenge", "method"]);

  app.command("pkce", "", "Generate a PKCE code_verifier and its S256 code_challenge", (CliContext c) {
    auto verifier = container.secrets.generate(48);
    auto data = Json.emptyObject;
    data["code_verifier"] = verifier;
    data["code_challenge"] = s256Challenge(verifier);
    data["code_challenge_method"] = "S256";
    return c.emit(data, TextTable.keyValue(data, ["code_verifier", "code_challenge", "code_challenge_method"]));
  }, []);

  app.command("introspect", "<token> [--hint=access_token|refresh_token]", "Show the state of a token (RFC 7662)",
    (CliContext c) {
    auto r = ports.introspection.introspect(TenantId(c.request.tenantId), c.operand(0, "token"), c.args.opt("hint"));
    auto row = introspectionRow(r);
    c.emit(row, TextTable.keyValue(row, ["active", "tokenType", "status", "clientId", "userId", "scope", "issuedAt", "expiresAt", "jti"]));
    return r.active ? 0 : 1;
  }, ["hint"]);

  app.command("revoke", "<token> [--hint=access_token|refresh_token]", "Revoke a token by its value (RFC 7009)", (CliContext c) {
    auto r = ports.introspection.revoke(TenantId(c.request.tenantId), c.operand(0, "token"), c.args.opt("hint"));
    return c.done(revocationRow(r), format("Revoked %s, %s", countOf(r.accessTokens, "access token"),
      countOf(r.refreshTokens, "refresh token")));
  }, ["hint"]);

  app.command("rotate-secret", "<clientKey> --yes", "Generate a new client secret (revokes the tokens of the client)",
    (CliContext c) {
    auto key = c.operand(0, "client key (OAuthClients id)");
    if (!c.args.flag("yes"))
      throw new CliUsageError("rotate-secret invalidates the old secret and revokes all tokens; confirm with --yes");
    auto p = Json.emptyObject;
    p["id"] = key;
    auto r = engine.invoke(c.request, "RotateClientSecret", p);
    return c.emit(r, TextTable.keyValue(r, ["clientId", "clientSecret", "secretRotatedAt", "revokedTokens"]));
  }, ["yes"]);

  app.command("revoke-client", "<clientKey>", "Revoke all tokens and codes of a client", (CliContext c) {
    auto p = Json.emptyObject;
    p["id"] = c.operand(0, "client key (OAuthClients id)");
    auto r = engine.invoke(c.request, "RevokeClientTokens", p);
    return c.done(r, format("Revoked %d access tokens, %d refresh tokens, %d codes", r["accessTokens"].get!long,
      r["refreshTokens"].get!long, r["codes"].get!long));
  }, []);

  app.command("purge", "", "Remove expired / revoked tokens and used / expired codes", (CliContext c) {
    auto r = engine.invoke(c.request, "PurgeExpired", Json.emptyObject);
    return c.done(r, format("Removed %d access tokens, %d refresh tokens, %d codes", r["accessTokens"].get!long,
      r["refreshTokens"].get!long, r["codes"].get!long));
  }, []);

  app.command("seed", "", "Load a demo scenario (branding, scopes, a service, a web and a native client) into an empty tenant",
    (CliContext c) {
    auto r = translated!DemoDataResult(() => seedDemoData(ports, TenantId(c.request.tenantId), UserId(c.request.actor)));
    auto data = Json.emptyObject;
    data["scopes"] = r.scopes;
    data["clients"] = r.clients;
    data["brandings"] = r.brandings;
    data["tokens"] = r.tokens;
    auto secrets = Json.emptyObject;
    foreach (k, v; r.secrets)
      secrets[k] = v;
    data["secrets"] = secrets;
    string text = format("Seeded tenant '%s': %d scopes, %d clients, %d branding, %d token\n", c.request.tenantId,
      r.scopes, r.clients, r.brandings, r.tokens);
    foreach (k; r.secrets.keys.sort)
      text ~= format("  client secret of %s: %s\n", k, r.secrets[k]);
    text ~= "Secrets are shown only once.";
    return c.done(data, text);
  }, []);

  app.command("config", "", "Show the effective configuration (secrets masked)", (CliContext c) {
    auto j = config.toMaskedJson();
    j["signingKey"] = container.signingKey.source;
    c.print(j.toPrettyString ~ "\n");
    return 0;
  }, []);

  return app;
}

/// Run a protocol use case; OAuth errors become CLI errors with the RFC code.
T protocolCall(T)(scope T delegate() @safe dg) {
  try
    return dg();
  catch (OAuthProtocolException e)
    throw new EntitySetException(e.httpStatus, cast(string) e.error, e.msg);
  catch (OAuthException e)
    throw toEntitySetException(e);
}

/// Configuration overrides from the bootstrap options.
Json[string] cliOverrides(CliArgs a) {
  Json[string] o;
  if (a.has("data-file")) {
    o["storage"] = "file";
    o["dataFile"] = a.opt("data-file");
  }
  if (a.has("storage"))
    o["storage"] = a.opt("storage");
  return o;
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  auto container = new OAuthContainer(loadOAuthConfig(o, "/nonexistent"));
  string out_;
  auto cli = buildOAuthCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed", "--json"]) == 0, out_);
  auto seeded = parseJsonString(out_);
  auto secret = seeded["secrets"]["sb-billing-service"].get!string;
  assert(cli.run(["seed"]) == 1); // tenant not empty → conflict

  // client credentials
  out_ = "";
  assert(cli.run(["token", "sb-billing-service", "--secret=" ~ secret, "--scope=orders.read", "--json"]) == 0, out_);
  auto token = parseJsonString(out_);
  assert(token["scope"].get!string == "orders.read" && "refresh_token" !in token);
  assert(cli.run(["token", "sb-billing-service", "--secret=wrong"]) == 1);
  assert(cli.run(["token", "sb-billing-service", "--secret=" ~ secret, "--scope=orders.write"]) == 1); // not allowed

  out_ = "";
  assert(cli.run(["introspect", token["access_token"].get!string, "--json"]) == 0, out_);
  assert(parseJsonString(out_)["active"].get!bool);
  assert(cli.run(["revoke", token["access_token"].get!string]) == 0);
  assert(cli.run(["introspect", token["access_token"].get!string]) == 1);

  // authorization code + PKCE for the public client
  out_ = "";
  assert(cli.run(["pkce", "--json"]) == 0);
  auto pkce = parseJsonString(out_);
  out_ = "";
  assert(cli.run(["authorize", "mobile-app", "--user=jane", "--scope=orders.read", "--challenge="
      ~ pkce["code_challenge"].get!string, "--json"]) == 0, out_);
  auto code = parseJsonString(out_)["code"].get!string;
  out_ = "";
  assert(cli.run(["token", "mobile-app", "--grant=authorization_code", "--code=" ~ code, "--verifier="
      ~ pkce["code_verifier"].get!string, "--json"]) == 0, out_);
  auto userToken = parseJsonString(out_);
  assert(userToken["refresh_token"].get!string.length > 0);
  // code replay → invalid_grant and the tokens are revoked
  assert(cli.run(["token", "mobile-app", "--grant=authorization_code", "--code=" ~ code, "--verifier="
      ~ pkce["code_verifier"].get!string]) == 1);
  assert(cli.run(["introspect", userToken["access_token"].get!string]) == 1);

  // management
  assert(cli.run(["rotate-secret", "billing-service"]) == 2); // needs --yes
  out_ = "";
  assert(cli.run(["rotate-secret", "billing-service", "--yes", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["clientSecret"].get!string != secret);
  assert(cli.run(["delete", "OAuthScopes", "orders.read", "--yes"]) == 1); // still allowed for clients → 422
  assert(cli.run(["list", "AccessTokens"]) == 0 && cli.run(["stats"]) == 0 && cli.run(["purge"]) == 0);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0);
}
