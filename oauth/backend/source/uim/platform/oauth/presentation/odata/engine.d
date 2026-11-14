/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST controller, the CLI and the GUI.
module uim.platform.oauth.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates OAuthException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

ODataEngine oauthEngine(OAuthPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(oauthModel());

  size_t[string] activeTokensByClient(TenantId t) {
    auto now = nowStdTime();
    size_t[string] counts;
    foreach (at; ports.tokens.listAccessTokens(t))
      if (at.isUsable(now))
        counts[at.clientId]++;
    return counts;
  }

  // ── Clients ───────────────────────────────────────────────────────────────
  auto clients = new DelegateEntitySetProvider;
  clients.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto active = activeTokensByClient(t);
    Json[] rows;
    foreach (e; ports.clients.listClients(t))
      rows ~= clientRow(e, active.get(e.clientId, 0));
    return rows;
  };
  clients.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.clients.getClient(t, OAuthClientId(key));
    return clientRow(e, activeTokensByClient(t).get(e.clientId, 0));
  };
  clients.onCreate = (const RequestContext ctx, Json p) {
    auto created = ports.clients.createClient(createClientRequest(ctx, p));
    return clientRow(created.client, 0, created.clientSecret);
  };
  clients.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.clients.updateClient(updateClientRequest(ctx, key, p));
    return clients.onGet(ctx, key);
  };
  clients.onRemove = (const RequestContext ctx, string key) {
    ports.clients.deleteClient(tenantOf(ctx), OAuthClientId(key));
  };

  // ── Scopes ────────────────────────────────────────────────────────────────
  size_t usage(TenantId t, string scopeName, OAuthClient[] all = null) {
    if (all is null)
      all = ports.clients.listClients(t);
    return all.count!(c => c.allowedScopes.canFind(scopeName));
  }

  auto scopes = new DelegateEntitySetProvider;
  scopes.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto all = ports.clients.listClients(t);
    Json[] rows;
    foreach (e; ports.scopes.listScopes(t))
      rows ~= scopeRow(e, usage(t, e.name, all));
    return rows;
  };
  scopes.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.scopes.getScope(t, OAuthScopeId(key));
    return scopeRow(e, usage(t, e.name));
  };
  scopes.onCreate = (const RequestContext ctx, Json p) => scopeRow(ports.scopes.createScope(createScopeRequest(ctx, p)));
  scopes.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.scopes.updateScope(updateScopeRequest(ctx, key, p));
    return scopes.onGet(ctx, key);
  };
  scopes.onRemove = (const RequestContext ctx, string key) {
    ports.scopes.deleteScope(tenantOf(ctx), OAuthScopeId(key));
  };

  // ── Access tokens (read, delete) ──────────────────────────────────────────
  auto accessTokens = new DelegateEntitySetProvider;
  accessTokens.onList = (const RequestContext ctx) {
    auto now = nowStdTime();
    Json[] rows;
    foreach (e; ports.tokens.listAccessTokens(tenantOf(ctx)))
      rows ~= accessTokenRow(e, now);
    return rows;
  };
  accessTokens.onGet = (const RequestContext ctx, string key) => accessTokenRow(
    ports.tokens.getAccessToken(tenantOf(ctx), AccessTokenId(key)), nowStdTime());
  accessTokens.onRemove = (const RequestContext ctx, string key) {
    ports.tokens.deleteAccessToken(tenantOf(ctx), AccessTokenId(key));
  };

  // ── Refresh tokens (read, delete = revoke + remove) ───────────────────────
  auto refreshTokens = new DelegateEntitySetProvider;
  refreshTokens.onList = (const RequestContext ctx) {
    auto now = nowStdTime();
    Json[] rows;
    foreach (e; ports.tokens.listRefreshTokens(tenantOf(ctx)))
      rows ~= refreshTokenRow(e, now);
    return rows;
  };
  refreshTokens.onGet = (const RequestContext ctx, string key) => refreshTokenRow(
    ports.tokens.getRefreshToken(tenantOf(ctx), RefreshTokenId(key)), nowStdTime());
  refreshTokens.onRemove = (const RequestContext ctx, string key) {
    ports.tokens.deleteRefreshToken(tenantOf(ctx), RefreshTokenId(key));
  };

  // ── Authorization codes (read, delete) ────────────────────────────────────
  auto codes = new DelegateEntitySetProvider;
  codes.onList = (const RequestContext ctx) {
    auto now = nowStdTime();
    Json[] rows;
    foreach (e; ports.tokens.listAuthorizationCodes(tenantOf(ctx)))
      rows ~= codeRow(e, now);
    return rows;
  };
  codes.onGet = (const RequestContext ctx, string key) => codeRow(
    ports.tokens.getAuthorizationCode(tenantOf(ctx), AuthorizationCodeId(key)), nowStdTime());
  codes.onRemove = (const RequestContext ctx, string key) {
    ports.tokens.deleteAuthorizationCode(tenantOf(ctx), AuthorizationCodeId(key));
  };

  // ── Brandings ─────────────────────────────────────────────────────────────
  size_t brandingUsers(TenantId t, string id) {
    return ports.clients.listClients(t).count!(c => c.brandingId == id);
  }

  auto brandings = new DelegateEntitySetProvider;
  brandings.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    size_t[string] users;
    foreach (c; ports.clients.listClients(t))
      if (c.brandingId.length)
        users[c.brandingId]++;
    Json[] rows;
    foreach (e; ports.brandings.listBrandings(t))
      rows ~= brandingRow(e, users.get(e.id.value, 0));
    return rows;
  };
  brandings.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    return brandingRow(ports.brandings.getBranding(t, BrandingConfigId(key)), brandingUsers(t, key));
  };
  brandings.onCreate = (const RequestContext ctx, Json p) => brandingRow(
    ports.brandings.createBranding(createBrandingRequest(ctx, p)));
  brandings.onUpdate = (const RequestContext ctx, string key, Json p) {
    ports.brandings.updateBranding(updateBrandingRequest(ctx, key, p));
    return brandings.onGet(ctx, key);
  };
  brandings.onRemove = (const RequestContext ctx, string key) {
    ports.brandings.deleteBranding(tenantOf(ctx), BrandingConfigId(key));
  };

  // ── Statistics (singleton) ────────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("OAuthClients", new PortProvider(clients))
    .provide("OAuthScopes", new PortProvider(scopes))
    .provide("AccessTokens", new PortProvider(accessTokens))
    .provide("RefreshTokens", new PortProvider(refreshTokens))
    .provide("AuthorizationCodes", new PortProvider(codes))
    .provide("BrandingConfigs", new PortProvider(brandings))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ───────────────────────────────────────────────────────────────
  engine.handle("RotateClientSecret", (const RequestContext ctx, Json p) => translated!Json(() => clientSecretRow(
      ports.clients.rotateSecret(tenantOf(ctx), OAuthClientId(textOf(p, "id")), actorOf(ctx)))));
  engine.handle("RevokeClientTokens", (const RequestContext ctx, Json p) => translated!Json(() {
      auto t = tenantOf(ctx);
      auto c = ports.clients.getClient(t, OAuthClientId(textOf(p, "id")));
      return revocationRow(ports.tokens.revokeClientTokens(t, c.clientId, RevocationReason.manual));
    }));
  engine.handle("RevokeAccessToken", (const RequestContext ctx, Json p) => translated!Json(() => revocationRow(
      ports.tokens.revokeAccessToken(tenantOf(ctx), AccessTokenId(textOf(p, "id")), RevocationReason.manual))));
  engine.handle("RevokeRefreshToken", (const RequestContext ctx, Json p) => translated!Json(() => revocationRow(
      ports.tokens.revokeRefreshToken(tenantOf(ctx), RefreshTokenId(textOf(p, "id")), RevocationReason.manual))));
  engine.handle("RequestClientToken", (const RequestContext ctx, Json p) => translated!Json(() {
      TokenRequest r;
      r.tenantId = tenantOf(ctx);
      r.grantType = cast(string) GrantType.clientCredentials;
      r.clientId = textOf(p, "clientId");
      r.clientSecret = textOf(p, "clientSecret");
      r.scope_ = textOf(p, "scope");
      return tokenResultRow(ports.issuer.exchange(r));
    }));
  engine.handle("IntrospectToken", (const RequestContext ctx, Json p) => translated!Json(() => introspectionRow(
      ports.introspection.introspect(tenantOf(ctx), textOf(p, "token"), textOf(p, "tokenTypeHint")))));
  engine.handle("PurgeExpired", (const RequestContext ctx, Json p) => translated!Json(() => revocationRow(
      ports.tokens.purgeExpired(tenantOf(ctx)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
