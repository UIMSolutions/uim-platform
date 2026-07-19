/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.repositories.oauth_scopes;

import uim.platform.oauth;
mixin(ShowModule!());

@safe:

interface OAuthScopeRepository  : ITenantRepository!(OAuthScope, OAuthScopeId) {

    size_t countByApplication(TenantId tenantId, string applicationId);
    OAuthScope[] findByApplication(TenantId tenantId, string applicationId);
    void removeByApplication(TenantId tenantId, string applicationId);

    size_t countByStatus(TenantId tenantId, ScopeStatus status);
    OAuthScope[] findByStatus(TenantId tenantId, ScopeStatus status);
    void removeByStatus(TenantId tenantId, ScopeStatus status);

}
