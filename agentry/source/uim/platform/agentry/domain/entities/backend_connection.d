/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.entities.backend_connection;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct BackendConnection {
    mixin TenantEntity!(BackendConnectionId);

    string name;
    string description;
    BackendType backendType = BackendType.s4hana;
    ConnectionStatus status = ConnectionStatus.inactive;
    string backendUrl;
    string clientId;
    string authMethod;    // basic, oauth2, saml
    string sysId;
    string sysNumber;
    string client;
    string language;
    string destinationName;
    string lastTestedAt;
    string lastTestedBy;
    bool sslEnabled;
    string certificateFingerprint;

    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("backendType", backendType.to!string)
            .set("status", status.to!string)
            .set("backendUrl", backendUrl)
            .set("clientId", clientId)
            .set("authMethod", authMethod)
            .set("sysId", sysId)
            .set("sysNumber", sysNumber)
            .set("client", client)
            .set("language", language)
            .set("destinationName", destinationName)
            .set("lastTestedAt", lastTestedAt)
            .set("lastTestedBy", lastTestedBy)
            .set("sslEnabled", sslEnabled)
            .set("certificateFingerprint", certificateFingerprint);
        return j;
    }
}
