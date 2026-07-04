/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.identity_provider;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct IdentityProvider {
    mixin TenantEntity!(IdentityProviderId);

    string name;
    string description;
    IdentityProviderType providerType;
    string clientId;
    string clientSecret;
    string issuerUrl;
    string metadataUrl;
    string redirectUri;
    string attributeMapping;
    string scopes;
    IdentityProviderStatus status = IdentityProviderStatus.inactive;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("providerType", providerType.to!string)
            .set("clientId", clientId)
            .set("issuerUrl", issuerUrl)
            .set("metadataUrl", metadataUrl)
            .set("redirectUri", redirectUri)
            .set("attributeMapping", attributeMapping)
            .set("scopes", scopes)
            .set("status", status.to!string);
    }
}
