module uim.platform.xyz.domain.ports.blocking_request_repository;

import domain.types;
import domain.entities.blocking_request;

/// Port for persisting data blocking / restriction requests.
interface BlockingRequestRepository
{
    BlockingRequest[] findByTenant(TenantId tenantId);
    BlockingRequest* findById(BlockingRequestId id, TenantId tenantId);
    BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status);
    void save(BlockingRequest request);
    void update(BlockingRequest request);
    void remove(BlockingRequestId id, TenantId tenantId);
}
