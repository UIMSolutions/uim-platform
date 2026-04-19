/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.refresh_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface RefreshTokenRepository {
    bool existsById(RefreshTokenId id);
    RefreshToken findById(RefreshTokenId id);
    RefreshToken findByTokenValue(string tokenValue);
    RefreshToken[] findAll();
    RefreshToken[] findByTenant(TenantId tenantId);
    RefreshToken[] findByClientId(string clientId);
    RefreshToken[] findByStatus(TokenStatus status);
    void save(RefreshToken entity);
    void update(RefreshToken entity);
    void remove(RefreshTokenId id);
}
