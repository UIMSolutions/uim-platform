/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.domain.entities.policy;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// An authorization policy: grants `action` on `resource` of an application,
/// optionally restricted by attribute conditions (all must match).
///
/// Business rules:
///  - resource and action are required; "*" is a wildcard, "Sales*" a prefix
///  - base policies are application templates: resource, action and
///    conditions are fixed (derive a custom policy to restrict them)
///  - disabled policies never grant access
struct AuthorizationPolicy {
  mixin TenantEntity!PolicyId;

  ManagedApplicationId applicationId;
  string name; /// unique per application
  string description;
  string resource;
  string action;
  PolicyCondition[] conditions;
  PolicyKind kind = PolicyKind.custom;
  PolicyStatus status = PolicyStatus.active;

  bool isBase() const {
    return kind == PolicyKind.base;
  }

  bool isActive() const {
    return status == PolicyStatus.active;
  }

  void enable() {
    if (isActive)
      throw AuthorizationException.ruleViolation("Policy '" ~ name ~ "' is already active");
    status = PolicyStatus.active;
  }

  void disable() {
    if (!isActive)
      throw AuthorizationException.ruleViolation("Policy '" ~ name ~ "' is already disabled");
    status = PolicyStatus.disabled;
  }

  void validate() const {
    if (applicationId.isNull)
      throw AuthorizationException.invalid("applicationId is required");
    if (name.strip.length == 0)
      throw AuthorizationException.invalid("Policy name is required");
    if (resource.strip.length == 0)
      throw AuthorizationException.invalid("Policy resource is required");
    if (action.strip.length == 0)
      throw AuthorizationException.invalid("Policy action is required");
    foreach (c; conditions) {
      if (c.attribute.strip.length == 0)
        throw AuthorizationException.invalid("Condition attribute is required");
      if (c.operator != ConditionOperator.exists && c.value.length == 0)
        throw AuthorizationException.invalid("Condition on '" ~ c.attribute ~ "' needs a value");
    }
  }
}

///
unittest {
  mixin(ShowTest!("AuthorizationPolicy"));

  AuthorizationPolicy p;
  p.applicationId = ManagedApplicationId("app");
  p.name = "reader";
  p.resource = "*";
  p.action = "Read";
  p.validate();
  p.disable();
  assert(!p.isActive);
  assert(failsWith(AuthorizationErrorKind.ruleViolation, () { p.disable(); }));
  p.enable();
  p.conditions = [PolicyCondition("country", ConditionOperator.eq, "")];
  assert(failsWith(AuthorizationErrorKind.invalid, () { p.validate(); }));
}
