/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.repositories.risk_rules;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class RiskRuleRepository : TenantRepository!(RiskRule, RiskRuleId), IRiskRuleRepository {
  mixin TenantRepositoryTemplate!(RiskRuleRepository, RiskRule, RiskRuleId);

  size_t countByRiskLevel(TenantId tenantId, RiskLevel riskLevel) {
    return countByTenant(tenantId, (RiskRule r) => r.riskLevel == riskLevel);
  }

  RiskRule[] findByRiskLevel(TenantId tenantId, RiskLevel riskLevel) {
    return findByTenant(tenantId).filter!(r => r.riskLevel == riskLevel).array;
  }

  void removeByRiskLevel(TenantId tenantId, RiskLevel riskLevel) {
    remove(findByRiskLevel(tenantId, riskLevel));
  }
}
///
unittest {
  assert(tenantRepositoryTest(new RiskRuleRepository()));
}
