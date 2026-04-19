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
    OAuthScopeId id;
    TenantId tenantId;
    string applicationId;
    string name;
    string description;
    ScopeStatus status = ScopeStatus.active;
    string createdAt;
    string updatedAt;
    string createdBy;
    string modifiedBy;

    Json oauthScopeToJson() {
        import std.conv : to;
        return Json.emptyObject
            .set("id", id.value)
            .set("tenantId", tenantId.value)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("status", status.to!string)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
