module uim.platform.data.privacy.domain.ports.blocking_request_repository;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.blocking_request;

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
