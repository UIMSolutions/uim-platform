/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.oauth_scope;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthScope {
    mixin TenantEntity!(OAuthScopeId);

    string applicationId;
    string name;
    string description;
    ScopeStatus status = ScopeStatus.active;

    Json toJson() const {
        return Json.entityToJson
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string);
    }
}
