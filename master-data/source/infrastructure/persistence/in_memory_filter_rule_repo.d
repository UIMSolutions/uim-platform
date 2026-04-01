module infrastructure.persistence.memory.filter_rule_repo;

import domain.types;
import domain.entities.filter_rule;
import domain.ports.filter_rule_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryFilterRuleRepository : FilterRuleRepository
{
    private FilterRule[FilterRuleId] store;

    FilterRule findById(FilterRuleId id)
    {
        if (auto p = id in store)
            return *p;
        return FilterRule.init;
    }

    FilterRule[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.category == category)
            .array;
    }

    FilterRule[] findActive(TenantId tenantId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.isActive)
            .array;
    }

    void save(FilterRule rule) { store[rule.id] = rule; }
    void update(FilterRule rule) { store[rule.id] = rule; }
    void remove(FilterRuleId id) { store.remove(id); }
}
