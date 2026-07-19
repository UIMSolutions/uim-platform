/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.refresh_tokens;

import uim.platform.oauth;
mixin(ShowModule!());

@safe:

interface RefreshTokenRepository : ITenantRepository!(RefreshToken, RefreshTokenId) {

    bool existsByTokenValue(TenantId tenantId, string tokenValue);
    RefreshToken findByTokenValue(TenantId tenantId, string tokenValue);
    void removeByTokenValue(TenantId tenantId, string tokenValue);

    size_t countByClient(TenantId tenantId, string clientId);
    RefreshToken[] findByClient(TenantId tenantId, string clientId);
    void removeByClient(TenantId tenantId, string clientId);

    size_t countByStatus(TenantId tenantId, TokenStatus status);
    RefreshToken[] findByStatus(TenantId tenantId, TokenStatus status);
    void removeByStatus(TenantId tenantId, TokenStatus status);

}
