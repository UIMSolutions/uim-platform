/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ⇄ record converters.
module uim.platform.authorization.persistence.mappers.entities;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

// ── applications ───────────────────────────────────────────────────────────
Json applicationToRecord(const ManagedApplication e) {
  auto d = auditRecord(e);
  d["name"] = e.name;
  d["organizationId"] = e.organizationId;
  d["description"] = e.description;
  return d;
}

ManagedApplication recordToApplication(Json d) {
  ManagedApplication e;
  readAudit(e, d);
  e.name = textField(d, "name");
  e.organizationId = textField(d, "organizationId");
  e.description = textField(d, "description");
  return e;
}

// ── application APIs ───────────────────────────────────────────────────────
Json apiToRecord(const ApplicationApi e) {
  auto d = auditRecord(e);
  d["applicationId"] = e.applicationId.value;
  d["name"] = e.name;
  d["endpoint"] = e.endpoint;
  d["operations"] = textsJson(e.operations);
  return d;
}

ApplicationApi recordToApi(Json d) {
  ApplicationApi e;
  readAudit(e, d);
  e.applicationId = ManagedApplicationId(textField(d, "applicationId"));
  e.name = textField(d, "name");
  e.endpoint = textField(d, "endpoint");
  e.operations = textsField(d, "operations");
  return e;
}

// ── policies ───────────────────────────────────────────────────────────────
Json policyToRecord(const AuthorizationPolicy e) {
  auto d = auditRecord(e);
  d["applicationId"] = e.applicationId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["resource"] = e.resource;
  d["action"] = e.action;
  auto conditions = Json.emptyArray;
  foreach (c; e.conditions)
    conditions ~= c.toJson;
  d["conditions"] = conditions;
  d["kind"] = cast(string) e.kind;
  d["status"] = cast(string) e.status;
  return d;
}

AuthorizationPolicy recordToPolicy(Json d) @trusted {
  AuthorizationPolicy e;
  readAudit(e, d);
  e.applicationId = ManagedApplicationId(textField(d, "applicationId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.resource = textField(d, "resource");
  e.action = textField(d, "action");
  if ("conditions" in d && d["conditions"].type == Json.Type.array)
    foreach (c; d["conditions"]) {
      PolicyCondition pc;
      pc.attribute = textField(c, "attribute");
      // legacy records used "op" with symbols like "=="
      auto op = textField(c, "operator");
      if (op.length == 0)
        op = textField(c, "op");
      try
        pc.operator = op.length ? parseOperator(op) : ConditionOperator.eq;
      catch (AuthorizationException)
        pc.operator = ConditionOperator.eq;
      pc.value = textField(c, "value");
      e.conditions ~= pc;
    }
  e.kind = boolField(d, "isBasePolicy") ? PolicyKind.base : enumField!PolicyKind(d, "kind", PolicyKind.custom);
  e.status = enumField!PolicyStatus(d, "status", PolicyStatus.active);
  return e;
}

// ── assignments ────────────────────────────────────────────────────────────
Json assignmentToRecord(const PolicyAssignment e) {
  auto d = auditRecord(e);
  d["policyId"] = e.policyId.value;
  d["principalType"] = cast(string) e.principalType;
  d["principalId"] = e.principalId;
  d["validFrom"] = e.validFrom;
  d["validTo"] = e.validTo;
  return d;
}

PolicyAssignment recordToAssignment(Json d) {
  PolicyAssignment e;
  readAudit(e, d);
  e.policyId = PolicyId(textField(d, "policyId"));
  e.principalType = enumField!PrincipalType(d, "principalType", PrincipalType.user);
  e.principalId = textField(d, "principalId");
  e.validFrom = longField(d, "validFrom");
  e.validTo = longField(d, "validTo");
  return e;
}

// ── decisions ──────────────────────────────────────────────────────────────
Json decisionToRecord(const DecisionRecord e) {
  auto d = auditRecord(e);
  d["principalId"] = e.principalId;
  d["groups"] = textsJson(e.groups);
  d["applicationId"] = e.applicationId.value;
  d["resource"] = e.resource;
  d["action"] = e.action;
  d["attributes"] = e.attributes;
  d["allowed"] = e.allowed;
  d["reason"] = e.reason;
  d["matchedPolicyIds"] = textsJson(e.matchedPolicyIds);
  d["channel"] = e.channel;
  return d;
}

DecisionRecord recordToDecision(Json d) {
  DecisionRecord e;
  readAudit(e, d);
  e.principalId = textField(d, "principalId");
  e.groups = textsField(d, "groups");
  e.applicationId = ManagedApplicationId(textField(d, "applicationId"));
  e.resource = textField(d, "resource");
  e.action = textField(d, "action");
  e.attributes = textField(d, "attributes");
  e.allowed = boolField(d, "allowed");
  e.reason = textField(d, "reason");
  e.matchedPolicyIds = textsField(d, "matchedPolicyIds");
  e.channel = textField(d, "channel");
  return e;
}

///
unittest {
  mixin(ShowTest!("entity mappers"));

  AuthorizationPolicy p;
  p.id = PolicyId("p1");
  p.tenantId = TenantId("t");
  p.applicationId = ManagedApplicationId("a");
  p.name = "support";
  p.resource = "Incident";
  p.action = "Read";
  p.conditions = parseConditions("country in US,CA; level ge 2");
  p.kind = PolicyKind.base;
  p.status = PolicyStatus.disabled;
  auto back = recordToPolicy(policyToRecord(p));
  assert(back.id == p.id && back.name == "support" && back.isBase && !back.isActive);
  assert(conditionsText(back.conditions) == "country in US,CA; level ge 2");

  // legacy record of the previous implementation
  auto legacy = parseJsonString(`{"id":"x","tenantId":"t","applicationId":"a","name":"n","resource":"*","action":"*",
    "isBasePolicy":true,"conditions":[{"attribute":"country","op":"==","value":"US"}]}`);
  auto old = recordToPolicy(legacy);
  assert(old.isBase && old.conditions[0].operator == ConditionOperator.eq);
}
