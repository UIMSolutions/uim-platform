module uim.platform.xyz.domain.ports.cleansing_rule_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.cleansing_rule;

/// Port for persisting data cleansing rules.
interface CleansingRuleRepository
{
    CleansingRule[] findAll();
    CleansingRule[] findByTenant(TenantId tenantId);
    CleansingRule* findById(RuleId id);
    CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern);
    CleansingRule[] findActive(TenantId tenantId);
    void save(CleansingRule rule);
    void update(CleansingRule rule);
    void remove(RuleId id, TenantId tenantId);
}
