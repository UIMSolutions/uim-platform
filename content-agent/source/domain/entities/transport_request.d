module domain.entities.transport_request;

import domain.types;

/// A request to transport one or more content packages between landscapes.
struct TransportRequest
{
    TransportRequestId id;
    TenantId tenantId;
    SubaccountId sourceSubaccount;
    SubaccountId targetSubaccount;
    string description;
    TransportStatus status = TransportStatus.created;
    TransportMode mode = TransportMode.cloudTransportManagement;
    ContentPackageId[] packageIds;
    TransportQueueId queueId;
    string createdBy;
    long createdAt;
    long updatedAt;
    long releasedAt;
    string errorMessage;
}
