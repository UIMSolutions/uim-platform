module infrastructure.persistence.memory.data_retrieval_repo;

import domain.types;
import domain.entities.data_retrieval_request;
import domain.ports.data_retrieval_request_repository;

class InMemoryDataRetrievalRequestRepository : DataRetrievalRequestRepository
{
    private DataRetrievalRequest[] store;

    DataRetrievalRequest[] findByTenant(TenantId tenantId)
    {
        DataRetrievalRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId)
                result ~= r;
        return result;
    }

    DataRetrievalRequest* findById(DataRetrievalRequestId id, TenantId tenantId)
    {
        foreach (ref r; store)
            if (r.id == id && r.tenantId == tenantId)
                return &r;
        return null;
    }

    DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        DataRetrievalRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId && r.dataSubjectId == dataSubjectId)
                result ~= r;
        return result;
    }

    DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status)
    {
        DataRetrievalRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId && r.status == status)
                result ~= r;
        return result;
    }

    void save(DataRetrievalRequest request)
    {
        store ~= request;
    }

    void update(DataRetrievalRequest request)
    {
        foreach (ref r; store)
            if (r.id == request.id && r.tenantId == request.tenantId)
            {
                r = request;
                return;
            }
    }

    void remove(DataRetrievalRequestId id, TenantId tenantId)
    {
        DataRetrievalRequest[] kept;
        foreach (ref r; store)
            if (!(r.id == id && r.tenantId == tenantId))
                kept ~= r;
        store = kept;
    }
}
