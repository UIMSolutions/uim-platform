module infrastructure.persistence.memory.cleansing_rule_repo;

import domain.types;
import domain.entities.cleansing_rule;
import domain.ports.cleansing_rule_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryCleansingRuleRepository : CleansingRuleRepository
{
    private CleansingRule[RuleId] store;

    CleansingRule[] findAll()
    {
        return store.byValue().array;
    }

    CleansingRule[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(r => r.tenantId == tenantId).array;
    }

    CleansingRule* findById(RuleId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.datasetPattern == datasetPattern)
            .array;
    }

    CleansingRule[] findActive(TenantId tenantId)
    {
        return store.byValue()
            .filter!(r => r.tenantId == tenantId && r.status == RuleStatus.active)
            .array;
    }

    void save(CleansingRule rule) { store[rule.id] = rule; }
    void update(CleansingRule rule) { store[rule.id] = rule; }
    void remove(RuleId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
