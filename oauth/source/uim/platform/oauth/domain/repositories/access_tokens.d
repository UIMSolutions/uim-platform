/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface AccessTokenRepository : ITenantRepository!(AccessToken, AccessTokenId) {

    bool existsByTokenValue(TenantId tenantId, string tokenValue);
    AccessToken findByTokenValue(TenantId tenantId, string tokenValue);
    void removeByTokenValue(TenantId tenantId, string tokenValue);

    size_t countByClientId(TenantId tenantId, string clientId);
    AccessToken[] findByClientId(TenantId tenantId, string clientId);
    void removeByClientId(TenantId tenantId, string clientId);

    size_t countByUserId(TenantId tenantId, UserId userId);
    AccessToken[] findByUserId(TenantId tenantId, UserId userId);
    void removeByUserId(TenantId tenantId, UserId userId);

    size_t countByStatus(TenantId tenantId, TokenStatus status);
    AccessToken[] findByStatus(TenantId tenantId, TokenStatus status);
    void removeByStatus(TenantId tenantId, TokenStatus status);

}
