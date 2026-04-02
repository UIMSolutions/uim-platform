module uim.platform.content_agent.domain.entities.transport_queue;

import domain.types;

/// A configured transport queue (CTS+, Cloud TMS, or local).
struct TransportQueue
{
    TransportQueueId id;
    TenantId tenantId;
    string name;
    string description;
    QueueType queueType = QueueType.cloudTMS;
    string endpoint;
    string authToken;
    bool isDefault;
    string createdBy;
    long createdAt;
    long updatedAt;
}
