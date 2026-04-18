module uim.platform.data_retention.infrastructure.persistence.memory.data_subjects;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRepository : DataSubjectRepository {
    private DataSubject[DataSubjectId] store;

    size_t countAll() { return store.length; }
    DataSubject[] findAll() { return store.byValue.array; }

    bool existsById(DataSubjectId id) { return (id in store) ? true : false; }
    DataSubject findById(DataSubjectId id) { return existsById(id) ? store[id] : DataSubject.init; }

    bool existsById(TenantId tenantId, DataSubjectId id) { return (id in store) ? true : false; }
    DataSubject findById(TenantId tenantId, DataSubjectId id) { return existsById(id) ? store[id] : DataSubject.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    DataSubject[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    DataSubject[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    DataSubject[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByTenant(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }
    DataSubject[] findByLifecycleStatus(TenantId tenantId, DataLifecycleStatus status) {
        return findByTenant(tenantId).filter!(a => a.lifecycleStatus == status).array;
    }
    DataSubject[] findByRole(TenantId tenantId, DataSubjectRoleId roleId) {
        return findByTenant(tenantId).filter!(a => a.roleId == roleId).array;
    }

    void save(DataSubject a) { store[a.id] = a; }
    void save(TenantId tenantId, DataSubject a) { store[a.id] = a; }
    void update(DataSubject a) { store[a.id] = a; }
    void update(TenantId tenantId, DataSubject a) { store[a.id] = a; }
    void remove(DataSubjectId id) { store.remove(id); }
    void remove(TenantId tenantId, DataSubjectId id) { store.remove(id); }
}
