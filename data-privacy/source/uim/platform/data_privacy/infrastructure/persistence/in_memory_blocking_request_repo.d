module infrastructure.persistence.memory.blocking_request_repo;

import domain.types;
import domain.entities.blocking_request;
import domain.ports.blocking_request_repository;

class MemoryBlockingRequestRepository : BlockingRequestRepository
{
    private BlockingRequest[] store;

    BlockingRequest[] findByTenant(TenantId tenantId)
    {
        BlockingRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId)
                result ~= r;
        return result;
    }

    BlockingRequest* findById(BlockingRequestId id, TenantId tenantId)
    {
        foreach (ref r; store)
            if (r.id == id && r.tenantId == tenantId)
                return &r;
        return null;
    }

    BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        BlockingRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId && r.dataSubjectId == dataSubjectId)
                result ~= r;
        return result;
    }

    BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status)
    {
        BlockingRequest[] result;
        foreach (ref r; store)
            if (r.tenantId == tenantId && r.status == status)
                result ~= r;
        return result;
    }

    void save(BlockingRequest request)
    {
        store ~= request;
    }

    void update(BlockingRequest request)
    {
        foreach (ref r; store)
            if (r.id == request.id && r.tenantId == request.tenantId)
            {
                r = request;
                return;
            }
    }

    void remove(BlockingRequestId id, TenantId tenantId)
    {
        BlockingRequest[] kept;
        foreach (ref r; store)
            if (!(r.id == id && r.tenantId == tenantId))
                kept ~= r;
        store = kept;
    }
}
