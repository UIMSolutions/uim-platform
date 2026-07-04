/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// External Identity Provider entity — corporate/social IdP federation.
module uim.platform.identity.domain.entities.identity_provider;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

struct IdentityProvider {
    mixin TenantEntity!(IdentityProviderId);

    string name;
    string description;
    IdpType type_ = IdpType.oidc;
    IdpStatus status = IdpStatus.active;
    string metadataUrl;         // SAML metadata URL or OIDC discovery URL
    string entityId;            // SAML entity ID / OIDC issuer
    string ssoUrl;              // Single Sign-On URL (SAML)
    string sloUrl;              // Single Logout URL (SAML)
    string certificate;         // Signing certificate (PEM)
    string clientId;            // OIDC client_id for this IdP
    string clientSecret;        // OIDC client_secret (hashed)
    string[] allowedDomains;    // Email domains that use this IdP
    bool isDefault;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("type", type_.to!string)
            .set("status", status.to!string)
            .set("entityId", entityId)
            .set("ssoUrl", ssoUrl)
            .set("sloUrl", sloUrl)
            .set("metadataUrl", metadataUrl)
            .set("isDefault", isDefault);
        auto domainsArr = Json.emptyArray;
        foreach (d; allowedDomains) domainsArr ~= Json(d);
        j["allowedDomains"] = domainsArr;
        return j;
    }
}
