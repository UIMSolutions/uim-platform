module uim.platform.data_retention.infrastructure.persistence.memory.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryResidenceRuleRepository : ResidenceRuleRepository {
    private ResidenceRule[ResidenceRuleId] store;

    size_t countAll() { return store.length; }
    ResidenceRule[] findAll() { return store.byValue.array; }

    bool existsById(ResidenceRuleId id) { return (id in store) ? true : false; }
    ResidenceRule findById(ResidenceRuleId id) { return existsById(id) ? store[id] : ResidenceRule.init; }

    bool existsById(TenantId tenantId, ResidenceRuleId id) { return (id in store) ? true : false; }
    ResidenceRule findById(TenantId tenantId, ResidenceRuleId id) { return existsById(id) ? store[id] : ResidenceRule.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    ResidenceRule[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    ResidenceRule[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    ResidenceRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    ResidenceRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByTenant(tenantId).filter!(a => a.legalGroundId == groundId).array;
    }

    void save(ResidenceRule a) { store[a.id] = a; }
    void save(TenantId tenantId, ResidenceRule a) { store[a.id] = a; }
    void update(ResidenceRule a) { store[a.id] = a; }
    void update(TenantId tenantId, ResidenceRule a) { store[a.id] = a; }
    void remove(ResidenceRuleId id) { store.remove(id); }
    void remove(TenantId tenantId, ResidenceRuleId id) { store.remove(id); }
}
