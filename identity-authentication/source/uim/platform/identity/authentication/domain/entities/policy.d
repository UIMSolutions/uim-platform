/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.domain.entities.policy;

// import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Authorization policy for controlling access to applications.
struct AuthorizationPolicy {
  mixin TenantEntity!PolicyId;

  string name;
  string description;
  PolicyRule[] rules;
  string[] applicationIds;
  bool active = true;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("rules", rules.map!(r => r.toJson()).array)
      .set("applicationIds", applicationIds)
      .set("active", active);
  }
}

/// A single rule within a policy.
struct PolicyRule {
  string attribute; // e.g., "group", "ip_range", "user_type", "auth_method"
  string operator_; // e.g., "eq", "in", "not_in", "matches"
  string value;

  Json toJson() {
    return Json.emptyObject
      .set("attribute", attribute)
      .set("operator", operator_)
      .set("value", value);
  }
}
