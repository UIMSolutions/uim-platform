module domain.ports.risk_rule_repository;

import domain.entities.risk_rule;
import domain.types;

/// Port: outgoing — risk rule persistence.
interface RiskRuleRepository
{
    RiskRule findById(string id);
    RiskRule[] findByTenant(TenantId tenantId);
    void save(RiskRule rule);
    void update(RiskRule rule);
    void remove(string id);
}
