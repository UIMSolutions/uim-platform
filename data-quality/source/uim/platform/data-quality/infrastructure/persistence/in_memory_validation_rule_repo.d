module infrastructure.persistence.in_memory_validation_rule_repo;

import domain.types;
import domain.entities.validation_rule;
import domain.ports.validation_rule_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryValidationRuleRepository : ValidationRuleRepository
{
    private ValidationRule[RuleId] store;

    ValidationRule[] findAll()
    {
        return store.byValue().array;
    }

    ValidationRule[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(r => r.tenantId == tenantId).array;
    }

    ValidationRule* findById(RuleId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.datasetPattern == datasetPattern)
            .array;
    }

    ValidationRule[] findByField(TenantId tenantId, string fieldName)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.fieldName == fieldName)
            .array;
    }

    ValidationRule[] findActive(TenantId tenantId)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.status == RuleStatus.active)
            .array;
    }

    void save(ValidationRule rule) { store[rule.id] = rule; }
    void update(ValidationRule rule) { store[rule.id] = rule; }
    void remove(RuleId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
