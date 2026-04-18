module uim.platform.data_retention.infrastructure.persistence.memory.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryLegalEntityRepository : LegalEntityRepository {
    private LegalEntity[LegalEntityId] store;

    size_t countAll() { return store.length; }
    LegalEntity[] findAll() { return store.byValue.array; }

    bool existsById(LegalEntityId id) { return (id in store) ? true : false; }
    LegalEntity findById(LegalEntityId id) { return existsById(id) ? store[id] : LegalEntity.init; }

    bool existsById(TenantId tenantId, LegalEntityId id) { return (id in store) ? true : false; }
    LegalEntity findById(TenantId tenantId, LegalEntityId id) { return existsById(id) ? store[id] : LegalEntity.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    LegalEntity[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    LegalEntity[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    LegalEntity[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void save(LegalEntity a) { store[a.id] = a; }
    void save(TenantId tenantId, LegalEntity a) { store[a.id] = a; }
    void update(LegalEntity a) { store[a.id] = a; }
    void update(TenantId tenantId, LegalEntity a) { store[a.id] = a; }
    void remove(LegalEntityId id) { store.remove(id); }
    void remove(TenantId tenantId, LegalEntityId id) { store.remove(id); }
}
