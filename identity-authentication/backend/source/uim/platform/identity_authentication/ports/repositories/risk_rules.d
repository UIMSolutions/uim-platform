/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.repositories.risk_rules;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driven port: risk rule persistence.
interface IRiskRuleRepository : ITenantRepository!(RiskRule, RiskRuleId) {
  size_t countByRiskLevel(TenantId tenantId, RiskLevel riskLevel);
  RiskRule[] findByRiskLevel(TenantId tenantId, RiskLevel riskLevel);
  void removeByRiskLevel(TenantId tenantId, RiskLevel riskLevel);
}
