/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthClientRepository : OAuthClientRepository {
    private OAuthClient[] store;

    bool existsById(OAuthClientId id) {
        return store.any!(e => e.id == id);
    }

    OAuthClient findById(OAuthClientId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return OAuthClient.init;
    }

    OAuthClient findByClientId(string clientId) {
        foreach (e; findAll)
            if (e.clientId == clientId) return e;
        return OAuthClient.init;
    }

    OAuthClient[] findAll() { return store; }

    OAuthClient[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    OAuthClient[] findByStatus(ClientStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(OAuthClient entity) { store ~= entity; }

    void update(OAuthClient entity) {
        foreach (ref e; findAll)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(OAuthClientId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
