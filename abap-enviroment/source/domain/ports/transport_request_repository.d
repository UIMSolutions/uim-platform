module domain.ports.transport_request_repository;

import domain.entities.transport_request;
import domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository
{
    TransportRequest* findById(TransportRequestId id);
    TransportRequest[] findBySystem(SystemInstanceId systemId);
    TransportRequest[] findByTenant(TenantId tenantId);
    TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status);
    TransportRequest[] findByOwner(SystemInstanceId systemId, string owner);
    void save(TransportRequest request);
    void update(TransportRequest request);
    void remove(TransportRequestId id);
}
