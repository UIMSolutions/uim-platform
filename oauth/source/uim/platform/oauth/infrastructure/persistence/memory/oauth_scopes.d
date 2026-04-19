/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthScopeRepository : OAuthScopeRepository {
    private OAuthScope[] store;

    bool existsById(OAuthScopeId id) {
        return store.any!(e => e.id == id);
    }

    OAuthScope findById(OAuthScopeId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return OAuthScope.init;
    }

    OAuthScope[] findAll() { return store; }

    OAuthScope[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    OAuthScope[] findByApplication(string applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    OAuthScope[] findByStatus(ScopeStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(OAuthScope entity) { store ~= entity; }

    void update(OAuthScope entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(OAuthScopeId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
