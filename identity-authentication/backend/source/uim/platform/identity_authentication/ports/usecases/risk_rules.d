/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.risk_rules;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: risk-based authentication rules.
interface IManageRiskRulesUseCase {
  RiskRule[] listRiskRules(TenantId tenantId);
  RiskRule getRiskRule(TenantId tenantId, RiskRuleId id);

  UsecaseResult createRiskRule(RiskRuleDTO dto);
  UsecaseResult updateRiskRule(RiskRuleDTO dto);
  UsecaseResult deleteRiskRule(TenantId tenantId, RiskRuleId id);

  /// Simulate a login of the user: data {"riskLevel", "requiredMfa", "denied", "triggeredRules"}.
  UsecaseResult assess(TenantId tenantId, UserId userId, RiskEvaluationContext ctx);
}
