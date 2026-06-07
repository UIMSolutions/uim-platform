/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Registered Application entity — OIDC/SAML applications.
module uim.platform.identity.domain.entities.application;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

struct Application {
    mixin TenantEntity!(ApplicationId);

    string name;
    string description;
    AppProtocol protocol = AppProtocol.oidc;
    AppStatus status = AppStatus.active;
    string clientId;            // OIDC client_id or SAML service provider entity ID
    string clientSecret;        // OIDC client_secret (hashed)
    string[] redirectUris;      // Allowed OAuth redirect URIs
    string[] scopes;            // Allowed OAuth scopes
    AuthScheme authScheme = AuthScheme.form;
    string subjectNameId;       // SAML NameID format
    string assertionConsumerUrl; // SAML ACS URL
    string logoUrl;
    string homepageUrl;
    bool multiTenantEnabled;
    bool riskBasedAuthEnabled;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("protocol", protocol.to!string)
            .set("status", status.to!string)
            .set("clientId", clientId)
            .set("authScheme", authScheme.to!string)
            .set("logoUrl", logoUrl)
            .set("homepageUrl", homepageUrl)
            .set("multiTenantEnabled", multiTenantEnabled)
            .set("riskBasedAuthEnabled", riskBasedAuthEnabled);
        auto redirectArr = Json.emptyArray;
        foreach (u; redirectUris) redirectArr ~= Json(u);
        j["redirectUris"] = redirectArr;
        auto scopeArr = Json.emptyArray;
        foreach (s; scopes) scopeArr ~= Json(s);
        j["scopes"] = scopeArr;
        return j;
    }
}
