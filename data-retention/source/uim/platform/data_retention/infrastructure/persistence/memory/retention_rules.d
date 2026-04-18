module uim.platform.data_retention.infrastructure.persistence.memory.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryRetentionRuleRepository : RetentionRuleRepository {
    private RetentionRule[RetentionRuleId] store;

    size_t countAll() { return store.length; }
    RetentionRule[] findAll() { return store.byValue.array; }

    bool existsById(RetentionRuleId id) { return (id in store) ? true : false; }
    RetentionRule findById(RetentionRuleId id) { return existsById(id) ? store[id] : RetentionRule.init; }

    bool existsById(TenantId tenantId, RetentionRuleId id) { return (id in store) ? true : false; }
    RetentionRule findById(TenantId tenantId, RetentionRuleId id) { return existsById(id) ? store[id] : RetentionRule.init; }

    bool existsByTenant(TenantId tenantId) { return store.byValue.any!(a => a.tenantId == tenantId); }
    size_t countByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array.length; }
    RetentionRule[] findByTenant(TenantId tenantId) { return store.byValue.filter!(a => a.tenantId == tenantId).array; }

    RetentionRule[] findAll(TenantId tenantId) { return findByTenant(tenantId); }
    RetentionRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    RetentionRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByTenant(tenantId).filter!(a => a.legalGroundId == groundId).array;
    }

    void save(RetentionRule a) { store[a.id] = a; }
    void save(TenantId tenantId, RetentionRule a) { store[a.id] = a; }
    void update(RetentionRule a) { store[a.id] = a; }
    void update(TenantId tenantId, RetentionRule a) { store[a.id] = a; }
    void remove(RetentionRuleId id) { store.remove(id); }
    void remove(TenantId tenantId, RetentionRuleId id) { store.remove(id); }
}
