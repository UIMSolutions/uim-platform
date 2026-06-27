/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.access_tokens;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

interface AccessTokenRepository : ITentRepository!(AccessToken, AccessTokenId) {

    bool existsByTokenValue(TenantId tenantId, string tokenValue);
    AccessToken findByTokenValue(TenantId tenantId, string tokenValue);
    void removeByTokenValue(TenantId tenantId, string tokenValue);

    size_t countByClient(TenantId tenantId, string clientId);
    AccessToken[] findByClient(TenantId tenantId, string clientId);
    void removeByClient(TenantId tenantId, string clientId);

    size_t countByUser(TenantId tenantId, UserId userId);
    AccessToken[] findByUser(TenantId tenantId, UserId userId);
    void removeByUser(TenantId tenantId, UserId userId);

    size_t countByStatus(TenantId tenantId, TokenStatus status);
    AccessToken[] findByStatus(TenantId tenantId, TokenStatus status);
    void removeByStatus(TenantId tenantId, TokenStatus status);

}
