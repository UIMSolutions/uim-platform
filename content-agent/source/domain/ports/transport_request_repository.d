module uim.platform.content_agent.domain.ports.transport_request_repository;

import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository
{
    TransportRequest findById(TransportRequestId id);
    TransportRequest[] findByTenant(TenantId tenantId);
    TransportRequest[] findByStatus(TenantId tenantId, TransportStatus status);
    void save(TransportRequest request);
    void update(TransportRequest request);
    void remove(TransportRequestId id);
}
