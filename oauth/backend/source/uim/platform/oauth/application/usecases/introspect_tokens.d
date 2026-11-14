/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.introspect_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class IntrospectTokensUseCase : IIntrospectTokens {
  protected OAuthRepositories repos;
  protected IManageTokens tokens;

  this(OAuthRepositories repos, IManageTokens tokens) {
    this.repos = repos;
    this.tokens = tokens;
  }

  /// The stored hash is authoritative: a token is only active if this server
  /// issued it, it is neither revoked nor expired and its client is active.
  IntrospectionResult introspect(TenantId tenantId, string token, string hint = "") {
    IntrospectionResult r;
    if (token.length == 0)
      return r;
    auto hash = fingerprint(token);
    auto now = nowStdTime();
    foreach (kind; hint == "refresh_token" ? ["refresh_token", "access_token"] : ["access_token", "refresh_token"]) {
      if (kind == "access_token") {
        auto at = repos.accessTokens.findByHash(tenantId, hash);
        if (at.isNull)
          continue;
        fill(r, kind, at.clientId, at.userId, at.scopes, at.issuedAt, at.expiresAt, at.id.value, at.tenantId.value,
          cast(string) at.effectiveStatus(now));
        r.active = at.isUsable(now) && clientActive(tenantId, at.clientId);
        return r;
      }
      auto rt = repos.refreshTokens.findByHash(tenantId, hash);
      if (rt.isNull)
        continue;
      fill(r, kind, rt.clientId, rt.userId, rt.scopes, rt.issuedAt, rt.expiresAt, rt.id.value, rt.tenantId.value,
        cast(string) rt.effectiveStatus(now));
      r.active = rt.isUsable(now) && clientActive(tenantId, rt.clientId);
      return r;
    }
    return r;
  }

  RevocationResult revoke(TenantId tenantId, string token, string hint = "", string requesterClientId = "") {
    RevocationResult result;
    if (token.length == 0)
      return result;
    auto hash = fingerprint(token);
    bool mine(string clientId) {
      return requesterClientId.length == 0 || requesterClientId == clientId;
    }

    auto rt = repos.refreshTokens.findByHash(tenantId, hash);
    if (!rt.isNull && mine(rt.clientId))
      result.add(tokens.revokeRefreshToken(tenantId, rt.id, RevocationReason.manual));
    auto at = repos.accessTokens.findByHash(tenantId, hash);
    if (!at.isNull && mine(at.clientId))
      result.add(tokens.revokeAccessToken(tenantId, at.id, RevocationReason.manual));
    return result;
  }

  protected bool clientActive(TenantId tenantId, string clientId) {
    auto c = repos.clients.findByClientId(tenantId, clientId);
    return !c.isNull && c.isActive;
  }

  protected static void fill(ref IntrospectionResult r, string kind, string clientId, string userId, const string[] scopes,
    long issuedAt, long expiresAt, string jti, string tenantId, string status) {
    r.tokenType = kind;
    r.clientId = clientId;
    r.userId = userId;
    r.scopes = scopes.dup;
    r.issuedAt = issuedAt;
    r.expiresAt = expiresAt;
    r.jti = jti;
    r.tenantId = tenantId;
    r.status = status;
  }
}
