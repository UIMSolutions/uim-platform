module uim.platform.data_retention.infrastructure.persistence.memory.business_purposes;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryBusinessPurposeRepository : BusinessPurposeRepository {
    private BusinessPurpose[BusinessPurposeId] store;

    size_t countAll() { return store.length; }
    BusinessPurpose[] findAll() { return store.byValue.array; }

    bool existsById(BusinessPurposeId id) { return (id in store) ? true : false; }
    BusinessPurpose findById(BusinessPurposeId id) { return existsById(id) ? store[id] : BusinessPurpose.init; }

    bool existsById(TenantId tenantId, BusinessPurposeId id) { return (id in store) ? true : false; }
    BusinessPurpose findById(TenantId tenantId, BusinessPurposeId id) { return existsById(id) ? store[id] : BusinessPurpose.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    BusinessPurpose[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    BusinessPurpose[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    BusinessPurpose[] findByApplicationGroup(TenantId tenantId, ApplicationGroupId groupId) {
        return findByTenant(tenantId).filter!(a => a.applicationGroupId == groupId).array;
    }
    BusinessPurpose[] findByStatus(TenantId tenantId, BusinessPurposeStatus status) {
        return findByTenant(tenantId).filter!(a => a.status == status).array;
    }

    void save(BusinessPurpose a) { store[a.id] = a; }
    void save(TenantId tenantId, BusinessPurpose a) { store[a.id] = a; }
    void update(BusinessPurpose a) { store[a.id] = a; }
    void update(TenantId tenantId, BusinessPurpose a) { store[a.id] = a; }
    void remove(BusinessPurposeId id) { store.remove(id); }
    void remove(TenantId tenantId, BusinessPurposeId id) { store.remove(id); }
}
