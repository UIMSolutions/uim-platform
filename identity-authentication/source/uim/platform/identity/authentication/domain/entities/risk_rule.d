/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.risk_rule;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Risk-based authentication rule.
struct RiskRule {
  mixin TenantEntity!RiskRuleId;

  string name;
  RiskCondition[] conditions;
  RiskLevel resultLevel;
  MfaType requiredMfa = MfaType.none; // MFA to enforce when rule triggers
  bool active = true;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("conditions", conditions.map!(c => c.toJson()).array)
      .set("resultLevel", resultLevel.to!string)
      .set("requiredMfa", requiredMfa.to!string)
      .set("active", active);
  }
}

/// Condition that triggers a risk evaluation.
struct RiskCondition {
  string conditionType; // "ip_range", "group", "user_type", "auth_method", "geo"
  string operator_; // "eq", "not_eq", "in", "not_in"
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("conditionType", conditionType)
      .set("operator", operator_)
      .set("value", value);
  }
}
