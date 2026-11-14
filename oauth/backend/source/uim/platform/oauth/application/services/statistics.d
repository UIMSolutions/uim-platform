/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.services.statistics;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthStatisticsService : IOAuthStatisticsService {
  protected OAuthRepositories repos;

  this(OAuthRepositories repos) {
    this.repos = repos;
  }

  OAuthStatistics compute(TenantId tenantId) {
    auto now = nowStdTime();
    OAuthStatistics s;
    s.tenantId = tenantId.value;
    foreach (c; repos.clients.findAll(tenantId)) {
      s.clients++;
      if (c.isActive)
        s.activeClients++;
      if (c.status == ClientStatus.blocked)
        s.blockedClients++;
      if (!c.isConfidential)
        s.publicClients++;
    }
    s.scopes = repos.scopes.countAll(tenantId);
    foreach (t; repos.accessTokens.findAll(tenantId))
      final switch (t.effectiveStatus(now)) {
      case TokenStatus.active:
        s.activeAccessTokens++;
        break;
      case TokenStatus.expired:
        s.expiredAccessTokens++;
        break;
      case TokenStatus.revoked:
        s.revokedAccessTokens++;
        break;
      }
    foreach (t; repos.refreshTokens.findAll(tenantId))
      if (t.isUsable(now))
        s.activeRefreshTokens++;
    foreach (c; repos.codes.findAll(tenantId))
      if (c.isRedeemable(now))
        s.pendingAuthorizationCodes++;
    s.brandings = repos.brandings.countAll(tenantId);
    return s;
  }
}
