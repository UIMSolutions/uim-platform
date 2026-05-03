/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthScopeRepository : TenantRepository!(OAuthScope, OAuthScopeId), OAuthScopeRepository {

    bool existsByName(string name) {
        return findAll().any!(e => e.name == name);
    }
    OAuthScope findByName(string name) {
        foreach (e; findAll)
            if (e.name == name) return e;
        return OAuthScope.init;
    }
    void removeByName(string name) {
        foreach (e; findAll)
            if (e.name == name) {
                remove(e);
                return;
            }
    }
    
    size_t countByApplication(string applicationId) {
        return findByApplication(applicationId).length;
    }
    OAuthScope[] findByApplication(string applicationId) {
        return findAll().filter!(e => e.applicationId == applicationId).array;
    }
    void removeByApplication(string applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

    size_t countByStatus(ScopeStatus status) {
        return findByStatus(status).length;
    }
    OAuthScope[] findByStatus(ScopeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(ScopeStatus status) {
        findByStatus(status).each!(e => remove(e));
    }


}
