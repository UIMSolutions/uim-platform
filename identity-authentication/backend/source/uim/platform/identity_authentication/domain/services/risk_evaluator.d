/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: risk-based authentication.
module uim.platform.identity_authentication.domain.services.risk_evaluator;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Facts about a login attempt.
struct RiskEvaluationContext {
  string ipAddress;
  string userAgent;
  AuthMethod authMethod = AuthMethod.form;
  /// Ids AND names of the user's groups.
  string[] userGroups;
}

/// Known condition types and operators (used by the validator).
enum string[] riskConditionTypes = ["ip_range", "group", "auth_method", "failed_logins", "user_agent"];
enum string[] riskOperators = ["eq", "ne", "in", "not_in", "gt", "ge", "contains"];

/// Outcome of the risk evaluation.
struct RiskAssessment {
  RiskLevel level = RiskLevel.low;
  /// Strongest second factor demanded by a triggered rule (none = no step-up).
  MfaType requiredMfa = MfaType.none;
  bool denied;
  /// Names of the triggered rules.
  string[] triggeredRules;
}

/// Evaluate all active rules: highest risk level wins, the MFA of the rule with
/// the highest level wins, any denying rule denies.
RiskAssessment assessRisk(const RiskRule[] rules, const IAUser user, const RiskEvaluationContext ctx) {
  RiskAssessment a;
  RiskLevel mfaLevel = RiskLevel.low;
  foreach (rule; rules) {
    if (!rule.active || !rule.conditions.all!(c => matchesCondition(c, user, ctx)))
      continue;
    a.triggeredRules ~= rule.name;
    if (rule.riskLevel > a.level)
      a.level = rule.riskLevel;
    if (rule.requiredMfa != MfaType.none && (a.requiredMfa == MfaType.none || rule.riskLevel >= mfaLevel)) {
      a.requiredMfa = rule.requiredMfa;
      mfaLevel = rule.riskLevel;
    }
    if (rule.denyAccess)
      a.denied = true;
  }
  return a;
}

/// Highest risk level of the triggered rules.
RiskLevel evaluateRisk(const RiskRule[] rules, const IAUser user, const RiskEvaluationContext ctx) {
  return assessRisk(rules, user, ctx).level;
}

/// Second factor demanded by the triggered rules.
MfaType requiredMfaForRisk(const RiskRule[] rules, const IAUser user, const RiskEvaluationContext ctx) {
  return assessRisk(rules, user, ctx).requiredMfa;
}

/// Evaluate one condition. Unknown condition types never match.
bool matchesCondition(const RiskCondition cond, const IAUser user, const RiskEvaluationContext ctx) {
  bool negative = cond.operator_ == "ne" || cond.operator_ == "not_in";
  auto values = cond.value.split(",").map!(v => v.strip).filter!(v => v.length > 0).array;

  bool matched;
  switch (cond.conditionType) {
  case "ip_range":
    matched = ipMatchesAny(ctx.ipAddress, cond.value);
    break;
  case "group":
    matched = values.any!(v => ctx.userGroups.canFind(v));
    break;
  case "auth_method":
    matched = values.any!(v => sicmp(v, enumValue(ctx.authMethod)) == 0);
    break;
  case "user_agent":
    matched = values.any!(v => ctx.userAgent.toLower.canFind(v.toLower));
    break;
  case "failed_logins":
    int limit;
    try
      limit = cond.value.strip.to!int;
    catch (Exception)
      return false;
    if (cond.operator_ == "gt")
      return user.failedLoginAttempts > limit;
    if (cond.operator_ == "ge")
      return user.failedLoginAttempts >= limit;
    matched = user.failedLoginAttempts == limit;
    break;
  default:
    return false;
  }
  return negative ? !matched : matched;
}
///
unittest {
  mixin(ShowTest!("assessRisk"));

  auto user = IAUser(TenantId("t"));
  user.failedLoginAttempts = 3;
  RiskEvaluationContext ctx;
  ctx.ipAddress = "203.0.113.9";
  ctx.userGroups = ["contractors"];

  RiskRule external;
  external.name = "outside corporate network";
  external.conditions = [RiskCondition("ip_range", "not_in", "10.0.0.0/8")];
  external.riskLevel = RiskLevel.medium;
  external.requiredMfa = MfaType.email;

  RiskRule brute;
  brute.name = "many failures";
  brute.conditions = [RiskCondition("failed_logins", "ge", "3")];
  brute.riskLevel = RiskLevel.high;
  brute.requiredMfa = MfaType.totp;

  RiskRule inactive = brute;
  inactive.active = false;
  inactive.denyAccess = true;

  auto a = assessRisk([external, brute, inactive], user, ctx);
  assert(a.level == RiskLevel.high);
  assert(a.requiredMfa == MfaType.totp);
  assert(!a.denied);
  assert(a.triggeredRules == ["outside corporate network", "many failures"]);

  ctx.ipAddress = "10.2.3.4";
  user.failedLoginAttempts = 0;
  assert(evaluateRisk([external, brute], user, ctx) == RiskLevel.low);
  assert(requiredMfaForRisk([external, brute], user, ctx) == MfaType.none);

  assert(matchesCondition(RiskCondition("group", "in", "contractors"), user, ctx));
  assert(!matchesCondition(RiskCondition("whatever", "eq", "x"), user, ctx));
}
