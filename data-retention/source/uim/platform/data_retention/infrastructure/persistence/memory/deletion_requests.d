module uim.platform.data_retention.infrastructure.persistence.memory.deletion_requests;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDeletionRequestRepository : DeletionRequestRepository {
    private DeletionRequest[DeletionRequestId] store;

    size_t countAll() { return store.length; }
    DeletionRequest[] findAll() { return store.byValue.array; }

    bool existsById(DeletionRequestId id) { return (id in store) ? true : false; }
    DeletionRequest findById(DeletionRequestId id) { return existsById(id) ? store[id] : DeletionRequest.init; }

    bool existsById(TenantId tenantId, DeletionRequestId id) { return (id in store) ? true : false; }
    DeletionRequest findById(TenantId tenantId, DeletionRequestId id) { return existsById(id) ? store[id] : DeletionRequest.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    DeletionRequest[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    DeletionRequest[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
        return findByTenant(tenantId).filter!(a => a.dataSubjectId == subjectId).array;
    }
    DeletionRequest[] findByStatus(TenantId tenantId, DeletionRequestStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }
    DeletionRequest[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByTenant(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }

    void save(DeletionRequest a) { store[a.id] = a; }
    void save(TenantId tenantId, DeletionRequest a) { store[a.id] = a; }
    void update(DeletionRequest a) { store[a.id] = a; }
    void update(TenantId tenantId, DeletionRequest a) { store[a.id] = a; }
    void remove(DeletionRequestId id) { store.remove(id); }
    void remove(TenantId tenantId, DeletionRequestId id) { store.remove(id); }
}
