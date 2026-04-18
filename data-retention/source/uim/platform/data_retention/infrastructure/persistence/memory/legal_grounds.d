module uim.platform.data_retention.infrastructure.persistence.memory.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryLegalGroundRepository : LegalGroundRepository {
    private LegalGround[LegalGroundId] store;

    size_t countAll() { return store.length; }
    LegalGround[] findAll() { return store.byValue.array; }

    bool existsById(LegalGroundId id) { return (id in store) ? true : false; }
    LegalGround findById(LegalGroundId id) { return existsById(id) ? store[id] : LegalGround.init; }

    bool existsById(TenantId tenantId, LegalGroundId id) { return (id in store) ? true : false; }
    LegalGround findById(TenantId tenantId, LegalGroundId id) { return existsById(id) ? store[id] : LegalGround.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    LegalGround[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    LegalGround[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    LegalGround[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    LegalGround[] findByType(TenantId tenantId, LegalGroundType type) {
        return findByTenant(tenantId).filter!(a => a.type == type).array;
    }

    void save(LegalGround a) { store[a.id] = a; }
    void save(TenantId tenantId, LegalGround a) { store[a.id] = a; }
    void update(LegalGround a) { store[a.id] = a; }
    void update(TenantId tenantId, LegalGround a) { store[a.id] = a; }
    void remove(LegalGroundId id) { store.remove(id); }
    void remove(TenantId tenantId, LegalGroundId id) { store.remove(id); }
}
