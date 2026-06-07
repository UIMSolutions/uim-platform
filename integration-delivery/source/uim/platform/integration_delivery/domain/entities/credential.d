/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.domain.entities.credential;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

struct Credential {
    mixin TenantEntity!(CredentialId);

    string name;
    string description;
    CredentialType credentialType = CredentialType.basicAuth;
    string username;
    string secretRef;
    string target;
    CredentialStatus status = CredentialStatus.active;
    long expiresAt;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("credentialType", credentialType.to!string)
            .set("username", username)
            .set("target", target)
            .set("status", status.to!string)
            .set("expiresAt", expiresAt);
    }
}
