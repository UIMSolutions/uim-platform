module domain.ports.deletion_request_repository;

import domain.types;
import domain.entities.deletion_request;

/// Port for persisting data deletion requests.
interface DeletionRequestRepository
{
    DeletionRequest[] findByTenant(TenantId tenantId);
    DeletionRequest* findById(DeletionRequestId id, TenantId tenantId);
    DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    DeletionRequest[] findByStatus(TenantId tenantId, DeletionStatus status);
    void save(DeletionRequest request);
    void update(DeletionRequest request);
    void remove(DeletionRequestId id, TenantId tenantId);
}
