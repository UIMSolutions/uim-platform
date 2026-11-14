/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.dtos.statistics;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Aggregated figures of a tenant.
struct OAuthStatistics {
  string tenantId;
  size_t clients;
  size_t activeClients;
  size_t blockedClients;
  size_t publicClients;
  size_t scopes;
  size_t activeAccessTokens;
  size_t expiredAccessTokens;
  size_t revokedAccessTokens;
  size_t activeRefreshTokens;
  size_t pendingAuthorizationCodes;
  size_t brandings;
}
