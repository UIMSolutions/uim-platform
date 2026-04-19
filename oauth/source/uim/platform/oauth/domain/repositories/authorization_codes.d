/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface AuthorizationCodeRepository {
    bool existsById(AuthorizationCodeId id);
    AuthorizationCode findById(AuthorizationCodeId id);
    AuthorizationCode findByCode(string code);
    AuthorizationCode[] findAll();
    AuthorizationCode[] findByTenant(TenantId tenantId);
    AuthorizationCode[] findByClientId(string clientId);
    AuthorizationCode[] findByStatus(AuthCodeStatus status);
    void save(AuthorizationCode entity);
    void update(AuthorizationCode entity);
    void remove(AuthorizationCodeId id);
}
