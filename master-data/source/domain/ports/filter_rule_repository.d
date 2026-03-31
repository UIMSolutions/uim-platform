module domain.ports.filter_rule_repository;

import domain.entities.filter_rule;
import domain.types;

/// Port: outgoing — filter rule persistence.
interface FilterRuleRepository
{
    FilterRule findById(FilterRuleId id);
    FilterRule[] findByTenant(TenantId tenantId);
    FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category);
    FilterRule[] findActive(TenantId tenantId);
    void save(FilterRule rule);
    void update(FilterRule rule);
    void remove(FilterRuleId id);
}
