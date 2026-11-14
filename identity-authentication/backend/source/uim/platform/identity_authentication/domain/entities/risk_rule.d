/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.risk_rule;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Risk-based authentication rule: if all conditions match, the login gets the
/// rule's risk level and (optionally) requires a second factor.
struct RiskRule {
  mixin TenantEntity!RiskRuleId;

  string name;
  RiskCondition[] conditions;
  RiskLevel riskLevel = RiskLevel.low;
  /// MFA enforced when the rule triggers (none = no step-up).
  MfaType requiredMfa = MfaType.none;
  /// Deny the login altogether when the rule triggers.
  bool denyAccess;
  bool active = true;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("conditions", conditions.map!(c => c.toJson()).array.toJson)
      .set("riskLevel", enumValue(riskLevel))
      .set("requiredMfa", enumValue(requiredMfa))
      .set("denyAccess", denyAccess)
      .set("active", active);
  }
}

/// Condition of a risk rule: <conditionType> <operator> <value>.
///   conditionType: ip_range | group | auth_method | failed_logins | user_agent
///   operator:      eq | ne | in | not_in | gt | ge | contains
struct RiskCondition {
  string conditionType;
  string operator_;
  string value;

  string toText() const {
    return conditionType ~ ":" ~ operator_ ~ ":" ~ value;
  }

  static RiskCondition parse(string text) {
    auto r = PolicyRule.parse(text);
    return RiskCondition(r.attribute, r.operator_, r.value);
  }

  Json toJson() const {
    return Json.emptyObject
      .set("conditionType", conditionType)
      .set("operator", operator_)
      .set("value", value);
  }
}
