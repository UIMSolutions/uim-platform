/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations of the authorization domain.
module uim.platform.authorization.domain.enumerations.authorization;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Who a policy is assigned to.
enum PrincipalType : string {
  user = "user",
  group = "group",
}

/// Lifecycle of a policy. Disabled policies are kept (and stay assigned) but
/// never grant access.
enum PolicyStatus : string {
  active = "active",
  disabled = "disabled",
}

/// Base policies are delivered with an application (templates, read-only
/// rules); custom policies are authored by administrators.
enum PolicyKind : string {
  base = "base",
  custom = "custom",
}

/// Comparison of a request attribute with the condition value.
enum ConditionOperator : string {
  eq = "eq",
  ne = "ne",
  contains = "contains",
  startsWith = "startsWith",
  endsWith = "endsWith",
  in_ = "in",
  notIn = "notIn",
  lt = "lt",
  le = "le",
  gt = "gt",
  ge = "ge",
  exists = "exists",
}

/// Parse an operator; accepts the legacy symbols ==, !=, <, <=, >, >=.
ConditionOperator parseOperator(string text) {
  switch (text.strip) {
  case "==", "=":
    return ConditionOperator.eq;
  case "!=", "<>", "neq":
    return ConditionOperator.ne;
  case "<":
    return ConditionOperator.lt;
  case "<=":
    return ConditionOperator.le;
  case ">":
    return ConditionOperator.gt;
  case ">=":
    return ConditionOperator.ge;
  default:
    return parseDomainEnum!ConditionOperator(text, "condition operator");
  }
}

///
unittest {
  mixin(ShowTest!("authorization enumerations"));

  assert(parseOperator("IN") == ConditionOperator.in_);
  assert(parseOperator("!=") == ConditionOperator.ne);
  assert(parseDomainEnumOr!PrincipalType("", PrincipalType.user) == PrincipalType.user);
  assert(parseDomainEnum!PolicyStatus("Disabled") == PolicyStatus.disabled);
  assert(domainEnumValues!PrincipalType == ["user", "group"]);
}
