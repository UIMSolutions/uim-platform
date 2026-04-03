module uim.platform.data.privacy.domain.ports.retention_rule_repository;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.retention_rule;

/// Port for persisting data retention rules.
interface RetentionRuleRepository
{
    RetentionRule[] findByTenant(TenantId tenantId);
    RetentionRule* findById(RetentionRuleId id, TenantId tenantId);
    RetentionRule* findDefault(TenantId tenantId);
    RetentionRule[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose);
    void save(RetentionRule rule);
    void update(RetentionRule rule);
    void remove(RetentionRuleId id, TenantId tenantId);
}
