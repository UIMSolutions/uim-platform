/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.infrastructure.persistence.memory.oauth_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class MemoryOAuthScopeRepository :TenantRepository!(OAuthScope, OAuthScopeId), OAuthScopeRepository {

    OAuthScope[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    OAuthScope[] findByApplication(string applicationId) {
        return findAll().filter!(e => e.applicationId == applicationId).array;
    }

    OAuthScope[] findByStatus(ScopeStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

ß
}
