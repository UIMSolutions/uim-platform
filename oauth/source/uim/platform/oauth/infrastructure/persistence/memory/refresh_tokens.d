/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.refresh_tokens;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

class MemoryRefreshTokenRepository : TenantRepository!(RefreshToken, RefreshTokenId), RefreshTokenRepository {

    // #region ByTokenValue
    bool existsByTokenValue(TenantId tenantId, string tokenValue) {
        return findByTokenValue(tenantId, tokenValue).id != RefreshTokenId.init;
    }

    RefreshToken findByTokenValue(TenantId tenantId, string tokenValue) {
        foreach (e; findByTenant(tenantId))
            if (e.tokenValue == tokenValue)
                return e;
        return RefreshToken.init;
    }

    void removeByTokenValue(TenantId tenantId, string tokenValue) {
        foreach (e; findByTenant(tenantId))
            if (e.tokenValue == tokenValue) {
                remove(e);
                return;
            }
    }
    // #endregion ByTokenValue

    // #region ByClientId
    size_t countByClient(TenantId tenantId, string clientId) {
        return findByClient(tenantId, clientId).length;
    }

    RefreshToken[] filterByClient(TenantId tenantId, string clientId) {
        return findByTenant(tenantId).filter!(e => e.clientId == clientId).array;
    }

    RefreshToken[] findByClient(TenantId tenantId, string clientId) {
        return filterByClient(tenantId, clientId);
    }

    void removeByClient(TenantId tenantId, string clientId) {
        findByClient(tenantId, clientId).each!(e => remove(e));
    }
    // #endregion ByClientId

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, TokenStatus status) {
        return findByStatus(tenantId, status).length;
    }

    RefreshToken[] filterByStatus(TenantId tenantId, TokenStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    RefreshToken[] findByStatus(TenantId tenantId, TokenStatus status) {
        return filterByStatus(tenantId, status);
    }

    void removeByStatus(TenantId tenantId, TokenStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
