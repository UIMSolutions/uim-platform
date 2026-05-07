/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAccessTokenRepository : TenantRepository!(AccessToken, AccessTokenId), AccessTokenRepository {

    bool existsByTokenValue(TenantId tenantId, string tokenValue) {
        foreach (e; findByTenant(tenantId))
            if (e.tokenValue == tokenValue)
                return true;
        return false;
    }

    AccessToken findByTokenValue(TenantId tenantId, string tokenValue) {
        foreach (e; findByTenant(tenantId))
            if (e.tokenValue == tokenValue)
                return e;
        return AccessToken.init;
    }
    void removeByTokenValue(TenantId tenantId, string tokenValue) {
        foreach (e; findByTenant(tenantId))
            if (e.tokenValue == tokenValue) {
                remove(e);
                return;
            }
    }

    size_t countByClientId(TenantId tenantId, string clientId) {
        return findByClientId(tenantId, clientId).length;
    }

    AccessToken[] filterByClientId(AccessToken[] tokens, string clientId) {
        return tokens.filter!(e => e.clientId == clientId).array;
    }

    AccessToken[] findByClientId(TenantId tenantId, string clientId) {
        return filterByClientId(findByTenant(tenantId), clientId);
    }

    void removeByClientId(TenantId tenantId, string clientId) {
        findByClientId(tenantId, clientId).each!(e => remove(e));
    }

    size_t countByUserId(TenantId tenantId, UserId userId) {
        return findByUserId(tenantId, userId).length;
    }

    AccessToken[] filterByUserId(AccessToken[] tokens, UserId userId) {
        return tokens.filter!(e => e.userId == userId).array;
    }

    AccessToken[] findByUserId(TenantId tenantId, UserId userId) {
        return filterByUserId(findByTenant(tenantId), userId);
    }

    void removeByUserId(TenantId tenantId, UserId userId) {
        findByUserId(tenantId, userId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, TokenStatus status) {
        return findByStatus(tenantId, status).length;
    }

    AccessToken[] filterByStatus(AccessToken[] tokens, TokenStatus status) {
        return tokens.filter!(e => e.status == status).array;
    }

    AccessToken[] findByStatus(TenantId tenantId, TokenStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, TokenStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
