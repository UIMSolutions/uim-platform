/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.repositories.authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAuthorizationCodeRepository : TenantRepository!(AuthorizationCode, AuthorizationCodeId), AuthorizationCodeRepository {

    // #region ByCode
    bool existsByCode(TenantId tenantId, string code) {
        return findByCode(tenantId, code).id != AuthorizationCodeId.init;
    }
    AuthorizationCode findByCode(TenantId tenantId, string code) {
        foreach (e; findByTenant(tenantId))
            if (e.code == code) return e;
        return AuthorizationCode.init;
    }
    void removeByCode(TenantId tenantId, string code) {
        foreach (e; findByTenant(tenantId))
            if (e.code == code) {
                remove(e);
                return;
            }   
    }
    // #endregion ByCode

    // #region ByClient
    size_t countByClient(TenantId tenantId, string clientId) {
        return findByClient(tenantId, clientId).length;
    }
    AuthorizationCode[] filterByClient(AuthorizationCode[] codes, string clientId) {
        return codes.filter!(e => e.clientId == clientId).array;
    }
    AuthorizationCode[] findByClient(TenantId tenantId, string clientId) {
        return filterByClient(findByTenant(tenantId), clientId);
    }
    void removeByClient(TenantId tenantId, string clientId) {
        findByClient(tenantId, clientId).each!(e => remove(e));
    }
    // #endregion ByClient

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, AuthCodeStatus status) {
        return findByStatus(tenantId, status).length;
    }
    AuthorizationCode[] filterByStatus(AuthorizationCode[] codes, AuthCodeStatus status) {
        return codes.filter!(e => e.status == status).array;
    }
    AuthorizationCode[] findByStatus(TenantId tenantId, AuthCodeStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, AuthCodeStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
    // #endregion ByStatus

}
