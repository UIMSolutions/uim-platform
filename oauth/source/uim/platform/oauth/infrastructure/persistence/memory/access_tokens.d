/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.repositories.access_tokens;

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

    size_t countByClient(TenantId tenantId, string clientId) {
        return findByClient(tenantId, clientId).length;
    }

    AccessToken[] filterByClient(AccessToken[] tokens, string clientId) {
        return tokens.filter!(e => e.clientId == clientId).array;
    }

    AccessToken[] findByClient(TenantId tenantId, string clientId) {
        return filterByClient(findByTenant(tenantId), clientId);
    }

    void removeByClient(TenantId tenantId, string clientId) {
        findByClient(tenantId, clientId).each!(e => remove(e));
    }

    size_t countByUser(TenantId tenantId, UserId userId) {
        return findByUser(tenantId, userId).length;
    }

    AccessToken[] filterByUser(AccessToken[] tokens, UserId userId) {
        return tokens.filter!(e => e.userId == userId).array;
    }

    AccessToken[] findByUser(TenantId tenantId, UserId userId) {
        return filterByUser(findByTenant(tenantId), userId);
    }

    void removeByUser(TenantId tenantId, UserId userId) {
        findByUser(tenantId, userId).each!(e => remove(e));
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
