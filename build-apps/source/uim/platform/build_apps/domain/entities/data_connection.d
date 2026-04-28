/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.entities.data_connection;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct DataConnection {
    DataConnectionId id;
    TenantId tenantId;
    ApplicationId applicationId;
    string name;
    string description;
    ConnectionType connectionType = ConnectionType.restApi;
    ConnectionStatus status = ConnectionStatus.pending;
    AuthMethod authMethod = AuthMethod.none;
    string baseUrl;
    string basePath;
    string credentials;
    string headers;
    string queryParams;
    string responseMapping;
    string destinationName;
    string createdAt;
    string updatedAt;
    UserId createdBy;
    UserId modifiedBy;

    Json dataConnectionToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("applicationId", applicationId)
            .set("name", name)
            .set("description", description)
            .set("connectionType", connectionType.to!string)
            .set("status", status.to!string)
            .set("authMethod", authMethod.to!string)
            .set("baseUrl", baseUrl)
            .set("basePath", basePath)
            .set("credentials", credentials)
            .set("headers", headers)
            .set("queryParams", queryParams)
            .set("responseMapping", responseMapping)
            .set("destinationName", destinationName)
            .set("createdAt", createdAt)
            .set("updatedAt", updatedAt)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy);
    }
}
