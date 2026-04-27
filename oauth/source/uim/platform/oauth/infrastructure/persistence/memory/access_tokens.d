/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.access_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryAccessTokenRepository :TenantRepository!(AccessToken, AccessTokenId), AccessTokenRepository {

    }

    AccessToken findByTokenValue(string tokenValue) {
        foreach (e; findAll)
            if (e.tokenValue == tokenValue) return e;
        return AccessToken.init;
    }

    AccessToken[] findAll() { return store; }

    AccessToken[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    AccessToken[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }

    AccessToken[] findByUserId(string userId) {
        return findAll().filter!(e => e.userId == userId).array;
    }

    AccessToken[] findByStatus(TokenStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(AccessToken entity) { store ~= entity; }

    void update(AccessToken entity) {
        foreach (ref e; findAll)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(AccessTokenId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
