module uim.platform.identity_authentication.domain.ports.risk_rule;

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
