module uim.platform.data.quality.domain.ports.validation_rule_repository;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;

/// Port for persisting validation rules.
interface ValidationRuleRepository
{
    ValidationRule[] findAll();
    ValidationRule[] findByTenant(TenantId tenantId);
    ValidationRule* findById(RuleId id);
    ValidationRule[] findByDataset(TenantId tenantId, string datasetPattern);
    ValidationRule[] findByField(TenantId tenantId, string fieldName);
    ValidationRule[] findActive(TenantId tenantId);
    void save(ValidationRule rule);
    void update(ValidationRule rule);
    void remove(RuleId id, TenantId tenantId);
}
