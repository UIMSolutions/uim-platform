module uim.platform.data.privacy.domain.ports.deletion_request_repository;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.deletion_request;

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
