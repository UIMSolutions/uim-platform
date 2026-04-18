module uim.platform.data_retention.infrastructure.persistence.memory.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryApplicationGroupRepository : ApplicationGroupRepository {
    private ApplicationGroup[ApplicationGroupId] store;

    size_t countAll() { return store.length; }
    ApplicationGroup[] findAll() { return store.byValue.array; }

    bool existsById(ApplicationGroupId id) { return (id in store) ? true : false; }
    ApplicationGroup findById(ApplicationGroupId id) { return existsById(id) ? store[id] : ApplicationGroup.init; }

    bool existsById(TenantId tenantId, ApplicationGroupId id) { return (id in store) ? true : false; }
    ApplicationGroup findById(TenantId tenantId, ApplicationGroupId id) { return existsById(id) ? store[id] : ApplicationGroup.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    ApplicationGroup[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    ApplicationGroup[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    ApplicationGroup[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void save(ApplicationGroup a) { store[a.id] = a; }
    void save(TenantId tenantId, ApplicationGroup a) { store[a.id] = a; }
    void update(ApplicationGroup a) { store[a.id] = a; }
    void update(TenantId tenantId, ApplicationGroup a) { store[a.id] = a; }
    void remove(ApplicationGroupId id) { store.remove(id); }
    void remove(TenantId tenantId, ApplicationGroupId id) { store.remove(id); }
}
