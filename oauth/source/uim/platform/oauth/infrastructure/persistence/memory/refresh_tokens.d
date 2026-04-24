/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.refresh_tokens;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryRefreshTokenRepository : RefreshTokenRepository {
    private RefreshToken[] store;

    bool existsById(RefreshTokenId id) {
        return store.any!(e => e.id == id);
    }

    RefreshToken findById(RefreshTokenId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return RefreshToken.init;
    }

    RefreshToken findByTokenValue(string tokenValue) {
        foreach (e; findAll)
            if (e.tokenValue == tokenValue) return e;
        return RefreshToken.init;
    }

    RefreshToken[] findAll() { return store; }

    RefreshToken[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    RefreshToken[] findByClientId(string clientId) {
        return findAll().filter!(e => e.clientId == clientId).array;
    }

    RefreshToken[] findByStatus(TokenStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(RefreshToken entity) { store ~= entity; }

    void update(RefreshToken entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(RefreshTokenId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
