module uim.platform.abap_enviroment.domain.ports.transport_request_repository;

import uim.platform.abap_enviroment.domain.entities.transport_request;
import uim.platform.abap_enviroment.domain.types;

/// Port: outgoing - transport request persistence.
interface TransportRequestRepository {
    TransportRequest* findById(TransportRequestId id);
    TransportRequest[] findBySystem(SystemInstanceId systemId);
    TransportRequest[] findByTenant(TenantId tenantId);
    TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status);
    TransportRequest[] findByOwner(SystemInstanceId systemId, string owner);
    void save(TransportRequest request);
    void update(TransportRequest request);
    void remove(TransportRequestId id);
}
