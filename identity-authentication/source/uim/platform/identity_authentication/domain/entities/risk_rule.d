module uim.platform.identity_authentication.domain.entities.risk_rule;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Risk-based authentication rule.
struct RiskRule
{
  string id;
  TenantId tenantId;
  string name;
  RiskCondition[] conditions;
  RiskLevel resultLevel;
  MfaType requiredMfa = MfaType.none; // MFA to enforce when rule triggers
  bool active = true;

  Json toJson()
  {
    return Json.emptyObject.set("id", id).set("tenantId", tenantId).set("name",
        name).set("conditions", conditions.map!(c => c.toJson).array)
      .set("resultLevel", to!string(resultLevel)).set("requiredMfa",
        to!string(requiredMfa)).set("active", active);
  }
}

/// Condition that triggers a risk evaluation.
struct RiskCondition
{
  string conditionType; // "ip_range", "group", "user_type", "auth_method", "geo"
  string operator_; // "eq", "not_eq", "in", "not_in"
  string value;
}
