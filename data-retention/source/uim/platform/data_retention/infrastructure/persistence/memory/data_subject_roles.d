module uim.platform.data_retention.infrastructure.persistence.memory.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRoleRepository : DataSubjectRoleRepository {
    private DataSubjectRole[DataSubjectRoleId] store;

    size_t countAll() { return store.length; }
    DataSubjectRole[] findAll() { return store.byValue.array; }

    bool existsById(DataSubjectRoleId id) { return (id in store) ? true : false; }
    DataSubjectRole findById(DataSubjectRoleId id) { return existsById(id) ? store[id] : DataSubjectRole.init; }

    bool existsById(TenantId tenantId, DataSubjectRoleId id) { return (id in store) ? true : false; }
    DataSubjectRole findById(TenantId tenantId, DataSubjectRoleId id) { return existsById(id) ? store[id] : DataSubjectRole.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    DataSubjectRole[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    DataSubjectRole[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    DataSubjectRole[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void save(DataSubjectRole a) { store[a.id] = a; }
    void save(TenantId tenantId, DataSubjectRole a) { store[a.id] = a; }
    void update(DataSubjectRole a) { store[a.id] = a; }
    void update(TenantId tenantId, DataSubjectRole a) { store[a.id] = a; }
    void remove(DataSubjectRoleId id) { store.remove(id); }
    void remove(TenantId tenantId, DataSubjectRoleId id) { store.remove(id); }
}
