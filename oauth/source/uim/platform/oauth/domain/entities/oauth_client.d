/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.oauth_client;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthClient {
    OAuthClientId id;
    TenantId tenantId;
    string clientId;
    string clientSecret;
    string name;
    string description;
    ClientType clientType = ClientType.confidential;
    ClientStatus status = ClientStatus.active;
    string redirectUris;
    string allowedScopes;
    string grantTypes;
    long accessTokenValidity = 3600;
    long refreshTokenValidity = 86400;
    string contacts;
    string createdAt;
    string updatedAt;
    string createdBy;
    string modifiedBy;

    Json oauthClientToJson() {
        import std.conv : to;
        return Json.emptyObject
            .set("id", id.value)
            .set("tenantId", tenantId.value)
            .set("clientId", clientId)
            .set("name", name)
            .set("description", description)
            .set("clientType", clientType.to!string)
            .set("status", status.to!string)
            .set("redirectUris", redirectUris)
            .set("allowedScopes", allowedScopes)
            .set("grantTypes", grantTypes)
            .set("accessTokenValidity", accessTokenValidity)
            .set("refreshTokenValidity", refreshTokenValidity)
            .set("contacts", contacts)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
