/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageTokensUseCase : IManageTokens {
  protected OAuthRepositories repos;

  this(OAuthRepositories repos) {
    this.repos = repos;
  }

  // ── access tokens ───────────────────────────────────────────────────────
  AccessToken[] listAccessTokens(TenantId tenantId) {
    return repos.accessTokens.findAll(tenantId);
  }

  AccessToken getAccessToken(TenantId tenantId, AccessTokenId id) {
    return repos.accessTokens.findById(tenantId, id).required("Access token '" ~ id.value ~ "'");
  }

  RevocationResult revokeAccessToken(TenantId tenantId, AccessTokenId id, RevocationReason reason) {
    auto t = getAccessToken(tenantId, id);
    RevocationResult r;
    if (t.revoke(reason, nowStdTime())) {
      repos.accessTokens.save(t);
      r.accessTokens++;
    }
    return r;
  }

  void deleteAccessToken(TenantId tenantId, AccessTokenId id) {
    getAccessToken(tenantId, id);
    repos.accessTokens.removeById(tenantId, id);
  }

  // ── refresh tokens ──────────────────────────────────────────────────────
  RefreshToken[] listRefreshTokens(TenantId tenantId) {
    return repos.refreshTokens.findAll(tenantId);
  }

  RefreshToken getRefreshToken(TenantId tenantId, RefreshTokenId id) {
    return repos.refreshTokens.findById(tenantId, id).required("Refresh token '" ~ id.value ~ "'");
  }

  RevocationResult revokeRefreshToken(TenantId tenantId, RefreshTokenId id, RevocationReason reason) {
    auto t = getRefreshToken(tenantId, id);
    auto now = nowStdTime();
    RevocationResult r;
    if (t.revoke(reason, now)) {
      repos.refreshTokens.save(t);
      r.refreshTokens++;
    }
    foreach (a; repos.accessTokens.findByRefreshToken(tenantId, t.id.value))
      if (a.revoke(RevocationReason.parentRevoked, now)) {
        repos.accessTokens.save(a);
        r.accessTokens++;
      }
    return r;
  }

  void deleteRefreshToken(TenantId tenantId, RefreshTokenId id) {
    revokeRefreshToken(tenantId, id, RevocationReason.manual);
    repos.refreshTokens.removeById(tenantId, id);
  }

  // ── authorization codes ─────────────────────────────────────────────────
  AuthorizationCode[] listAuthorizationCodes(TenantId tenantId) {
    return repos.codes.findAll(tenantId);
  }

  AuthorizationCode getAuthorizationCode(TenantId tenantId, AuthorizationCodeId id) {
    return repos.codes.findById(tenantId, id).required("Authorization code '" ~ id.value ~ "'");
  }

  void deleteAuthorizationCode(TenantId tenantId, AuthorizationCodeId id) {
    getAuthorizationCode(tenantId, id);
    repos.codes.removeById(tenantId, id);
  }

  // ── bulk ────────────────────────────────────────────────────────────────
  RevocationResult revokeClientTokens(TenantId tenantId, string clientId, RevocationReason reason) {
    auto now = nowStdTime();
    RevocationResult r;
    foreach (t; repos.accessTokens.findByClient(tenantId, clientId))
      if (t.revoke(reason, now)) {
        repos.accessTokens.save(t);
        r.accessTokens++;
      }
    foreach (t; repos.refreshTokens.findByClient(tenantId, clientId))
      if (t.revoke(reason, now)) {
        repos.refreshTokens.save(t);
        r.refreshTokens++;
      }
    foreach (c; repos.codes.findByClient(tenantId, clientId))
      if (c.status == AuthCodeStatus.active) {
        c.status = AuthCodeStatus.revoked;
        repos.codes.save(c);
        r.codes++;
      }
    return r;
  }

  RevocationResult purgeExpired(TenantId tenantId) {
    auto now = nowStdTime();
    RevocationResult r;
    foreach (t; repos.accessTokens.findAll(tenantId))
      if (t.effectiveStatus(now) != TokenStatus.active && repos.accessTokens.removeById(tenantId, t.id))
        r.accessTokens++;
    // rotated refresh tokens stay until they expire: they detect replays
    foreach (t; repos.refreshTokens.findAll(tenantId))
      if ((isExpiredAt(t.expiresAt, now) || (t.status == TokenStatus.revoked && !t.wasRotated))
        && repos.refreshTokens.removeById(tenantId, t.id))
        r.refreshTokens++;
    // used codes stay until they expire: they detect replays
    foreach (c; repos.codes.findAll(tenantId))
      if ((isExpiredAt(c.expiresAt, now) || c.status == AuthCodeStatus.revoked) && repos.codes.removeById(tenantId, c.id))
        r.codes++;
    return r;
  }
}
