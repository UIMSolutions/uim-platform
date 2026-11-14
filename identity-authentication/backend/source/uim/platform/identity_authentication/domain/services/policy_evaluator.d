/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain service: evaluates authorization policies against a user.
module uim.platform.identity_authentication.domain.services.policy_evaluator;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Facts about the access attempt.
struct PolicyEvaluationContext {
  string ipAddress;
  AuthMethod authMethod = AuthMethod.form;
  /// Ids AND names of the user's groups (rules may reference either).
  string[] userGroups;
  bool mfaUsed;
}

/// Known rule attributes and operators (used by the validator).
enum string[] policyAttributes = ["group", "ip_range", "auth_method", "mfa", "user_status"];
enum string[] policyOperators = ["eq", "ne", "in", "not_in"];

/// True if the user satisfies all rules of the policy. Inactive policies grant.
bool evaluatePolicy(const AuthorizationPolicy policy, const IAUser user, const PolicyEvaluationContext ctx) {
  if (!policy.active)
    return true;
  return policy.rules.all!(rule => evaluateRule(rule, user, ctx));
}

/// The policies (of those given) that deny access.
AuthorizationPolicy[] findDenyingPolicies(AuthorizationPolicy[] policies, const IAUser user,
    const PolicyEvaluationContext ctx) {
  return policies.filter!(p => !evaluatePolicy(p, user, ctx)).array;
}

/// Evaluate a single rule. Unknown attributes deny (fail closed).
bool evaluateRule(const PolicyRule rule, const IAUser user, const PolicyEvaluationContext ctx) {
  bool positive = rule.operator_ == "eq" || rule.operator_ == "in";
  auto values = rule.value.split(",").map!(v => v.strip).filter!(v => v.length > 0).array;

  bool matched;
  switch (rule.attribute) {
  case "group":
    matched = values.any!(v => ctx.userGroups.canFind(v));
    break;
  case "ip_range":
    matched = ipMatchesAny(ctx.ipAddress, rule.value);
    break;
  case "auth_method":
    matched = values.any!(v => sicmp(v, enumValue(ctx.authMethod)) == 0);
    break;
  case "mfa":
    matched = (ctx.mfaUsed ? "true" : "false") == rule.value.strip.toLower;
    break;
  case "user_status":
    matched = values.any!(v => sicmp(v, enumValue(user.status)) == 0);
    break;
  default:
    return false;
  }
  return positive ? matched : !matched;
}
///
unittest {
  mixin(ShowTest!("evaluatePolicy"));

  auto user = IAUser(TenantId("t"));
  PolicyEvaluationContext ctx;
  ctx.ipAddress = "10.1.1.1";
  ctx.userGroups = ["g1", "admins"];

  AuthorizationPolicy p;
  p.rules = [PolicyRule("group", "in", "admins, ops"), PolicyRule("ip_range", "in", "10.0.0.0/8")];
  assert(evaluatePolicy(p, user, ctx));

  p.rules ~= PolicyRule("mfa", "eq", "true");
  assert(!evaluatePolicy(p, user, ctx));
  ctx.mfaUsed = true;
  assert(evaluatePolicy(p, user, ctx));

  p.rules = [PolicyRule("group", "not_in", "admins")];
  assert(!evaluatePolicy(p, user, ctx));
  p.rules = [PolicyRule("bogus", "eq", "x")];
  assert(!evaluatePolicy(p, user, ctx));
  p.active = false;
  assert(evaluatePolicy(p, user, ctx));
  assert(findDenyingPolicies([p], user, ctx).length == 0);
}
