/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.policy;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Authorization policy controlling access to applications. A user is granted
/// access if ALL rules of every active policy assigned to the application match.
struct AuthorizationPolicy {
  mixin TenantEntity!PolicyId;

  string name;
  string description;
  PolicyRule[] rules;
  /// Applications the policy applies to (empty = all applications of the tenant).
  string[] applicationIds;
  bool active = true;

  bool appliesTo(ApplicationId appId) const {
    return applicationIds.length == 0 || applicationIds.canFind(appId.value);
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("rules", rules.map!(r => r.toJson()).array.toJson)
      .set("applicationIds", applicationIds.map!(s => Json(s)).array.toJson)
      .set("active", active);
  }
}

/// A single rule of a policy: <attribute> <operator> <value>.
///   attribute: group | ip_range | auth_method | mfa | user_status
///   operator:  eq | ne | in | not_in
struct PolicyRule {
  string attribute;
  string operator_;
  string value;

  /// "group:in:admins"
  string toText() const {
    return attribute ~ ":" ~ operator_ ~ ":" ~ value;
  }

  /// Parse "attribute:operator:value" (the value may contain further colons).
  static PolicyRule parse(string text) {
    auto parts = text.strip.splitter(':').array;
    PolicyRule r;
    if (parts.length >= 1) r.attribute = parts[0].strip;
    if (parts.length >= 2) r.operator_ = parts[1].strip;
    if (parts.length >= 3) r.value = parts[2 .. $].join(":").strip;
    return r;
  }

  Json toJson() const {
    return Json.emptyObject
      .set("attribute", attribute)
      .set("operator", operator_)
      .set("value", value);
  }
}
///
unittest {
  mixin(ShowTest!("PolicyRule"));

  auto r = PolicyRule.parse("ip_range:in:10.0.0.0/8");
  assert(r.attribute == "ip_range" && r.operator_ == "in" && r.value == "10.0.0.0/8");
  assert(PolicyRule.parse("group:eq:a:b").value == "a:b");
  assert(r.toText == "ip_range:in:10.0.0.0/8");

  AuthorizationPolicy p;
  assert(p.appliesTo(ApplicationId("any")));
  p.applicationIds = ["a1"];
  assert(p.appliesTo(ApplicationId("a1")) && !p.appliesTo(ApplicationId("a2")));
}
