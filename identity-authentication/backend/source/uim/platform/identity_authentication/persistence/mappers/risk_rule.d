/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.risk_rule;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// RiskRule ⇄ snapshot record.
struct RiskRuleMapper {
  static Json toRecord(const RiskRule e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    auto conditions = Json.emptyArray;
    foreach (c; e.conditions)
      conditions ~= c.toJson;
    r["conditions"] = conditions;
    r["riskLevel"] = enumValue(e.riskLevel);
    r["requiredMfa"] = enumValue(e.requiredMfa);
    r["denyAccess"] = e.denyAccess;
    r["active"] = e.active;
    return r;
  }

  static RiskRule fromRecord(Json r) {
    RiskRule e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    foreach (c; fieldObjects(r, "conditions"))
      e.conditions ~= RiskCondition(fieldString(c, "conditionType"), fieldString(c, "operator"), fieldString(c, "value"));
    e.riskLevel = fieldEnum!RiskLevel(r, "riskLevel", RiskLevel.low);
    e.requiredMfa = fieldEnum!MfaType(r, "requiredMfa", MfaType.none);
    e.denyAccess = fieldBool(r, "denyAccess");
    e.active = fieldBool(r, "active", true);
    return e;
  }
}
///
unittest {
  mixin(ShowTest!("RiskRuleMapper"));

  auto rule = RiskRule(TenantId("t1"));
  rule.name = "External";
  rule.conditions = [RiskCondition("ip_range", "not_in", "10.0.0.0/8")];
  rule.riskLevel = RiskLevel.high;
  rule.requiredMfa = MfaType.totp;
  rule.denyAccess = true;
  auto back = RiskRuleMapper.fromRecord(RiskRuleMapper.toRecord(rule));
  assert(back.conditions == rule.conditions && back.riskLevel == RiskLevel.high);
  assert(back.requiredMfa == MfaType.totp && back.denyAccess);
}
