/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_scopes;

import uim.platform.oauth;

// mixin(ShowModule!());

@safe:

class MemoryOAuthScopeRepository : TentRepository!(OAuthScope, OAuthScopeId), OAuthScopeRepository {

    bool existsByName(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
    OAuthScope findByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId))
            if (e.name == name) return e;
        return OAuthScope.init;
    }
    void removeByName(TenantId tenantId, string name) {
        foreach (e; findByTenant(tenantId))
            if (e.name == name) {
                remove(e);
                return;
            }
    }
    
    size_t countByApplication(TenantId tenantId, string applicationId) {
        return findByApplication(tenantId, applicationId).length;
    }
    OAuthScope[] filterByApplication(OAuthScope[] scopes, string applicationId) {
        return scopes.filter!(e => e.applicationId == applicationId).array;
    }
    OAuthScope[] findByApplication(TenantId tenantId, string applicationId) {
        return filterByApplication(findByTenant(tenantId), applicationId);
    }
    void removeByApplication(TenantId tenantId, string applicationId) {
        findByApplication(tenantId, applicationId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ScopeStatus status) {
        return findByStatus(tenantId, status).length;
    }
    OAuthScope[] filterByStatus(OAuthScope[] scopes, ScopeStatus status) {
        return scopes.filter!(e => e.status == status).array;
    }
    OAuthScope[] findByStatus(TenantId tenantId, ScopeStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, ScopeStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }


}
