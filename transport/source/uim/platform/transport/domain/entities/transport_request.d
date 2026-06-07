/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_request;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

/// A unit of transport: an MTA archive, integration content package, HTML5 app, etc.
/// Created by source systems (CI/CD pipelines, SAP Cloud Integration) and forwarded
/// along transport routes through the import queues.
struct TransportRequest {
    mixin TenantEntity!TransportRequestId;

    string name;
    string description;
    string externalId;
    ContentType contentType = ContentType.mtaArchive;
    RequestStatus status = RequestStatus.initial;
    string version_;
    string contentSize;
    string storageUrl;
    string checksum;
    TransportNodeId sourceNodeId;
    string namedUser;
    string systemId;
    string description2;
    long queuedAt;
    long importedAt;
    string errorMessage;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("externalId", externalId)
            .set("contentType", contentType.to!string)
            .set("status", status.to!string)
            .set("version", version_)
            .set("contentSize", contentSize)
            .set("storageUrl", storageUrl)
            .set("checksum", checksum)
            .set("sourceNodeId", sourceNodeId.value)
            .set("namedUser", namedUser)
            .set("systemId", systemId)
            .set("queuedAt", queuedAt)
            .set("importedAt", importedAt)
            .set("errorMessage", errorMessage);
    }
}
