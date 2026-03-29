module uim.platform.identity_authentication.infrastructure.persistence.in_memory_risk_rule;

import uim.platform.identity_authentication.domain.entities.risk_rule;
import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication.domain.ports.risk_rule;

/// In-memory adapter for risk rule persistence.
class InMemoryRiskRuleRepository : RiskRuleRepository
{
    private RiskRule[string] store;

    RiskRule findById(string id)
    {
        if (auto p = id in store)
            return *p;
        return RiskRule.init;
    }

    RiskRule[] findByTenant(TenantId tenantId)
    {
        RiskRule[] result;
        foreach (r; store.byValue())
        {
            if (r.tenantId == tenantId)
                result ~= r;
        }
        return result;
    }

    void save(RiskRule rule)
    {
        store[rule.id] = rule;
    }

    void update(RiskRule rule)
    {
        store[rule.id] = rule;
    }

    void remove(string id)
    {
        store.remove(id);
    }
}
