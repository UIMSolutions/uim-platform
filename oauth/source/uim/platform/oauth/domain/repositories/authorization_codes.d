/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.authorization_codes;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

interface AuthorizationCodeRepository : ITenantRepository!(AuthorizationCode, AuthorizationCodeId) {

    bool existsByCode(TenantId tenantId, string code);
    AuthorizationCode findByCode(TenantId tenantId, string code);
    void removeByCode(TenantId tenantId, string code);

    size_t countByClient(TenantId tenantId, string clientId);
    AuthorizationCode[] findByClient(TenantId tenantId, string clientId);
    void removeByClient(TenantId tenantId, string clientId);

    size_t countByStatus(TenantId tenantId, AuthCodeStatus status);
    AuthorizationCode[] findByStatus(TenantId tenantId, AuthCodeStatus status);
    void removeByStatus(TenantId tenantId, AuthCodeStatus status);

}
