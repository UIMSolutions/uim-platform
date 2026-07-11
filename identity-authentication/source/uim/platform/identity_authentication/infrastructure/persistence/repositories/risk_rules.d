/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.repositories.risk_rules;
// import uim.platform.identity_authentication.domain.entities.risk_rule;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.risk_rule;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for risk rule persistence.
class MemoryRiskRuleRepository : TenantRepository!(RiskRule, RiskRuleId), RiskRuleRepository {

    size_t findByRiskLevel(TenantId tenantId, RiskLevel riskLevel) {
        size_t count = 0;
        foreach (r; findByTenant(tenantId)) {
            if (r.riskLevel == riskLevel)
                count++;
        }
        return count;
    }

    RiskRule[] filterByRiskLevel(RiskRule[] rules, RiskLevel riskLevel) {
        return rules.filter!(r => r.riskLevel == riskLevel).array;
    }

    RiskRule[] findByRiskLevel(TenantId tenantId, RiskLevel riskLevel) { // Todo Next: size_t offset = 0, size_t limit = 100);
        return filterByRiskLevel(findByTenant(tenantId), riskLevel);
    }
    void removeByRiskLevel(TenantId tenantId, RiskLevel riskLevel) {
        findByRiskLevel(tenantId, riskLevel).each!((r) => remove(r));
    }

}
