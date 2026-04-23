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

    size_t countByApplication(string applicationId);
    OAuthScope[] findByApplication(string applicationId);
    void removeByApplication(string applicationId);

    size_t countByStatus(ScopeStatus status);
    OAuthScope[] findByStatus(ScopeStatus status);
    void removeByStatus(ScopeStatus status);

}
