/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface AccessTokenRepository {
    bool existsById(AccessTokenId id);
    AccessToken findById(AccessTokenId id);
    AccessToken findByTokenValue(string tokenValue);
    AccessToken[] findAll();
    AccessToken[] findByTenant(TenantId tenantId);
    AccessToken[] findByClientId(string clientId);
    AccessToken[] findByUserId(string userId);
    AccessToken[] findByStatus(TokenStatus status);
    void save(AccessToken entity);
    void update(AccessToken entity);
    void remove(AccessTokenId id);
}
