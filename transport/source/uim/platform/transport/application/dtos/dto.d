/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.dto;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportNodeDTO {
    TransportNodeId nodeId;
    TenantId tenantId;
    string name;
    string description;
    string nodeType;
    string status;
    string environment;
    string region;
    string globalAccount;
    string subaccountId;
    SpaceId spaceId;
    string serviceKey;
    bool isForwardEnabled;
    bool autoImport;
    string autoImportSchedule;
    UserId createdBy;
    UserId updatedBy;
}

struct TransportRouteDTO {
    TransportRouteId routeId;
    TenantId tenantId;
    string name;
    string description;
    string sourceNodeId;
    string destinationNodeId;
    string status;
    bool isSequential;
    int sequence;
    UserId createdBy;
    UserId updatedBy;
}

struct TransportRequestDTO {
    TransportRequestId requestId;
    TenantId tenantId;
    string name;
    string description;
    string externalId;
    string contentType;
    string status;
    string version_;
    string contentSize;
    string storageUrl;
    string checksum;
    string sourceNodeId;
    string namedUser;
    string systemId;
    UserId createdBy;
}

struct ImportQueueEntryDTO {
    ImportQueueEntryId entryId;
    TenantId tenantId;
    string nodeId;
    string requestId;
    string status;
    int queuePosition;
    bool isSelected;
    string scheduledAt;
    UserId createdBy;
}

struct TransportActionDTO {
    TransportActionId actionId;
    TenantId tenantId;
    string actionType;
    string actionStatus;
    string nodeId;
    string requestId;
    string routeId;
    string performedBy;
    string description;
    string logDetails;
}
