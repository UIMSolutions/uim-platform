module uim.platform.abap_enviroment.domain.entities.transport_request;

import uim.platform.abap_enviroment.domain.types;

/// Individual task within a transport request.
struct TransportTask
{
    string taskId;
    string owner;
    TransportStatus status = TransportStatus.modifiable;
    string description;
    string[] objectList;
    long createdAt;
    long releasedAt;
}

/// Transport request for managing changes between systems (CTS-like).
struct TransportRequest
{
    TransportRequestId id;
    TenantId tenantId;
    SystemInstanceId sourceSystemId;
    SystemInstanceId targetSystemId;
    string description;
    string owner;

    TransportType transportType = TransportType.workbench;
    TransportStatus status = TransportStatus.modifiable;

    /// Tasks belonging to this request
    TransportTask[] tasks;

    /// Metadata
    long createdAt;
    long releasedAt;
    long importedAt;
}
