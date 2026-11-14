/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure decision logic (no I/O): which policies grant a request.
module uim.platform.authorization.domain.services.policy_evaluator;

import std.uni : icmp;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// What is asked: may <principal> do <action> on <resource> of <application>?
struct AccessRequest {
  string principalId;
  string[] groups;
  ManagedApplicationId applicationId;
  string resource;
  string action;
  string[string] attributes;
  long at; /// evaluation time (std time); 0 = now
}

/// The answer.
struct AccessDecision {
  bool allowed;
  string reason;
  string[] matchedPolicyIds;
  string[] matchedPolicyNames;
  size_t candidatePolicies; /// effective assignments of the principal in this application
}

class PolicyEvaluator {
  /// "*" matches everything, "Sales*" is a prefix, otherwise exact (case sensitive).
  bool resourceMatches(string policyResource, string requested) const {
    auto p = policyResource.strip;
    if (p == "*")
      return true;
    if (p.endsWith("*"))
      return requested.startsWith(p[0 .. $ - 1]);
    return p == requested;
  }

  /// "*" matches everything; otherwise a comma list of actions, case insensitive.
  bool actionMatches(string policyAction, string requested) const {
    foreach (a; splitList(policyAction))
      if (a == "*" || icmp(a, requested.strip) == 0)
        return true;
    return false;
  }

  bool conditionMatches(const PolicyCondition c, const string[string] attributes) const {
    auto actualPtr = c.attribute in attributes;
    if (c.operator == ConditionOperator.exists)
      return actualPtr !is null && (*actualPtr).strip.length > 0;
    if (actualPtr is null)
      return c.operator == ConditionOperator.ne || c.operator == ConditionOperator.notIn;

    auto actual = (*actualPtr).strip;
    auto expected = c.value.strip;
    final switch (c.operator) {
    case ConditionOperator.eq:
      return actual == expected;
    case ConditionOperator.ne:
      return actual != expected;
    case ConditionOperator.contains:
      return actual.canFind(expected);
    case ConditionOperator.startsWith:
      return actual.startsWith(expected);
    case ConditionOperator.endsWith:
      return actual.endsWith(expected);
    case ConditionOperator.in_:
      return splitList(expected).canFind(actual);
    case ConditionOperator.notIn:
      return !splitList(expected).canFind(actual);
    case ConditionOperator.lt:
      return compare(actual, expected) < 0;
    case ConditionOperator.le:
      return compare(actual, expected) <= 0;
    case ConditionOperator.gt:
      return compare(actual, expected) > 0;
    case ConditionOperator.ge:
      return compare(actual, expected) >= 0;
    case ConditionOperator.exists:
      return true; // handled above
    }
  }

  bool conditionsMatch(const PolicyCondition[] conditions, const string[string] attributes) const {
    return conditions.all!(c => conditionMatches(c, attributes));
  }

  /// Decide a request against the policies of its application and the
  /// assignments of the tenant. Access is granted if at least one active,
  /// effectively assigned policy matches resource, action and all conditions.
  AccessDecision decide(const AccessRequest request, const AuthorizationPolicy[] policies,
    const PolicyAssignment[] assignments) const {
    AccessDecision d;
    auto at = request.at != 0 ? request.at : nowStdTime();

    bool[string] assigned;
    foreach (a; assignments)
      if (a.appliesTo(request.principalId, request.groups) && a.isEffective(at))
        assigned[a.policyId.value] = true;

    foreach (p; policies) {
      if (p.applicationId != request.applicationId || (p.id.value in assigned) is null)
        continue;
      d.candidatePolicies++;
      if (!p.isActive)
        continue;
      if (!resourceMatches(p.resource, request.resource) || !actionMatches(p.action, request.action))
        continue;
      if (!conditionsMatch(p.conditions, request.attributes))
        continue;
      d.matchedPolicyIds ~= p.id.value;
      d.matchedPolicyNames ~= p.name;
    }

    d.allowed = d.matchedPolicyIds.length > 0;
    if (d.allowed)
      d.reason = "Granted by " ~ d.matchedPolicyNames.join(", ");
    else if (d.candidatePolicies == 0)
      d.reason = "No policy of the application is assigned to the principal";
    else
      d.reason = format("None of %d assigned policies grants %s on %s", d.candidatePolicies, request.action,
        request.resource);
    return d;
  }

  /// Numeric comparison if both sides are numbers, else lexicographic.
  protected static int compare(string a, string b) @trusted {
    try {
      auto x = a.to!double;
      auto y = b.to!double;
      return x < y ? -1 : (x > y ? 1 : 0);
    } catch (Exception) {
      return cmp(a, b);
    }
  }
}

///
unittest {
  mixin(ShowTest!("PolicyEvaluator"));

  auto e = new PolicyEvaluator;
  assert(e.resourceMatches("*", "Incident") && e.resourceMatches("Inc*", "Incident"));
  assert(!e.resourceMatches("Incident", "incident"));
  assert(e.actionMatches("read", "Read") && e.actionMatches("Read, Write", "write") && !e.actionMatches("Read", "Delete"));

  auto attrs = ["country": "US", "level": "10", "dept": "Sales"];
  assert(e.conditionMatches(PolicyCondition("country", ConditionOperator.in_, "US, CA"), attrs));
  assert(e.conditionMatches(PolicyCondition("level", ConditionOperator.gt, "9"), attrs)); // numeric, not "10" < "9"
  assert(e.conditionMatches(PolicyCondition("region", ConditionOperator.ne, "EU"), attrs)); // missing ≠ EU
  assert(!e.conditionMatches(PolicyCondition("region", ConditionOperator.eq, "EU"), attrs));
  assert(e.conditionMatches(PolicyCondition("dept", ConditionOperator.exists, ""), attrs));

  auto app = ManagedApplicationId("app");
  AuthorizationPolicy reader;
  reader.id = PolicyId("p1");
  reader.applicationId = app;
  reader.name = "reader-us";
  reader.resource = "*";
  reader.action = "Read";
  reader.conditions = [PolicyCondition("country", ConditionOperator.eq, "US")];

  PolicyAssignment viaGroup;
  viaGroup.policyId = reader.id;
  viaGroup.principalType = PrincipalType.group;
  viaGroup.principalId = "Support";

  AccessRequest r;
  r.principalId = "alice";
  r.groups = ["Support"];
  r.applicationId = app;
  r.resource = "Incident";
  r.action = "read";
  r.attributes = attrs;
  auto granted = e.decide(r, [reader], [viaGroup]);
  assert(granted.allowed && granted.matchedPolicyNames == ["reader-us"], granted.reason);

  r.attributes["country"] = "DE";
  auto denied = e.decide(r, [reader], [viaGroup]);
  assert(!denied.allowed && denied.candidatePolicies == 1);

  r.groups = null;
  assert(e.decide(r, [reader], [viaGroup]).candidatePolicies == 0);

  reader.status = PolicyStatus.disabled;
  r.groups = ["Support"];
  r.attributes["country"] = "US";
  assert(!e.decide(r, [reader], [viaGroup]).allowed);
}
