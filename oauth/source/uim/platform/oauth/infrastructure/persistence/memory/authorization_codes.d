/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.authorization_codes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAuthorizationCodeRepository : TenantRepository!(AuthorizationCode, AuthorizationCodeId), AuthorizationCodeRepository {

    AuthorizationCode findByCode(string code) {
        foreach (e; findAll)
            if (e.code == code) return e;
        return AuthorizationCode.init;
    }

    AuthorizationCode[] findAll() { return store; }

    AuthorizationCode[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    AuthorizationCode[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }

    AuthorizationCode[] findByStatus(AuthCodeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(AuthorizationCode entity) { store ~= entity; }

    void update(AuthorizationCode entity) {
        foreach (ref e; findAll)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(AuthorizationCodeId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
