module uim.platform.data.privacy.domain.ports.data_retrieval_request_repository;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_retrieval_request;

/// Port for persisting data subject access / retrieval requests.
interface DataRetrievalRequestRepository
{
    DataRetrievalRequest[] findByTenant(TenantId tenantId);
    DataRetrievalRequest* findById(DataRetrievalRequestId id, TenantId tenantId);
    DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status);
    void save(DataRetrievalRequest request);
    void update(DataRetrievalRequest request);
    void remove(DataRetrievalRequestId id, TenantId tenantId);
}
