/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.persistence.mappers.policy;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// AuthorizationPolicy ⇄ snapshot record.
struct PolicyMapper {
  static Json toRecord(const AuthorizationPolicy e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    auto rules = Json.emptyArray;
    foreach (rule; e.rules)
      rules ~= rule.toJson;
    r["rules"] = rules;
    r["applicationIds"] = stringsRecord(e.applicationIds);
    r["active"] = e.active;
    return r;
  }

  static AuthorizationPolicy fromRecord(Json r) {
    AuthorizationPolicy e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    foreach (rule; fieldObjects(r, "rules"))
      e.rules ~= PolicyRule(fieldString(rule, "attribute"), fieldString(rule, "operator"), fieldString(rule, "value"));
    e.applicationIds = fieldStrings(r, "applicationIds");
    e.active = fieldBool(r, "active", true);
    return e;
  }
}
///
unittest {
  mixin(ShowTest!("PolicyMapper"));

  auto p = AuthorizationPolicy(TenantId("t1"));
  p.name = "Admins";
  p.rules = [PolicyRule("group", "in", "admins"), PolicyRule("ip_range", "in", "10.0.0.0/8")];
  p.applicationIds = ["a1"];
  p.active = false;
  auto back = PolicyMapper.fromRecord(PolicyMapper.toRecord(p));
  assert(back.rules == p.rules && back.applicationIds == ["a1"] && !back.active);
}
