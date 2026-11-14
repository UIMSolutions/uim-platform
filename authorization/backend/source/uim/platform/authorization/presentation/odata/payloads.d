/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.authorization.presentation.odata.payloads;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool boolOf(Json p, string key, bool fallback = false) {
  return key in p && p[key].type == Json.Type.bool_ ? p[key].get!bool : fallback;
}

long longOf(Json p, string key, long fallback = 0) {
  return key in p && p[key].type == Json.Type.int_ ? p[key].get!long : fallback;
}

string[] textsOf(Json p, string key) @trusted {
  string[] values;
  if (key in p && p[key].type == Json.Type.array)
    foreach (v; p[key])
      if (v.type == Json.Type.string)
        values ~= v.get!string;
  return values;
}

/// The keys present in a (merge) payload.
FieldSet fieldsOf(Json p) {
  FieldSet f;
  if (p.isObject)
    foreach (k, _; p.get!(Json[string]))
      f.mark(k);
  return f;
}

CreateApplicationRequest createApplicationRequest(const RequestContext ctx, Json p) {
  CreateApplicationRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.name = textOf(p, "name");
  r.organizationId = textOf(p, "organizationId");
  r.description = textOf(p, "description");
  return r;
}

UpdateApplicationRequest updateApplicationRequest(const RequestContext ctx, string key, Json p) {
  UpdateApplicationRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ManagedApplicationId(key);
  r.fields = fieldsOf(p);
  r.name = textOf(p, "name");
  r.organizationId = textOf(p, "organizationId");
  r.description = textOf(p, "description");
  return r;
}

CreateApplicationApiRequest createApiRequest(const RequestContext ctx, Json p) {
  CreateApplicationApiRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.applicationId = ManagedApplicationId(textOf(p, "applicationId"));
  r.name = textOf(p, "name");
  r.endpoint = textOf(p, "endpoint");
  r.operations = textsOf(p, "operations");
  return r;
}

UpdateApplicationApiRequest updateApiRequest(const RequestContext ctx, string key, Json p) {
  UpdateApplicationApiRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = ApplicationApiId(key);
  r.fields = fieldsOf(p);
  r.name = textOf(p, "name");
  r.endpoint = textOf(p, "endpoint");
  r.operations = textsOf(p, "operations");
  return r;
}

CreatePolicyRequest createPolicyRequest(const RequestContext ctx, Json p) {
  CreatePolicyRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.applicationId = ManagedApplicationId(textOf(p, "applicationId"));
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.resource = textOf(p, "resource");
  r.action = textOf(p, "action");
  r.conditions = parseConditions(textOf(p, "conditions"));
  r.kind = parseDomainEnumOr!PolicyKind(textOf(p, "kind"), PolicyKind.custom, "kind");
  r.status = parseDomainEnumOr!PolicyStatus(textOf(p, "status"), PolicyStatus.active, "status");
  return r;
}

UpdatePolicyRequest updatePolicyRequest(const RequestContext ctx, string key, Json p) {
  UpdatePolicyRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = PolicyId(key);
  r.fields = fieldsOf(p);
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.resource = textOf(p, "resource");
  r.action = textOf(p, "action");
  r.conditions = parseConditions(textOf(p, "conditions"));
  r.status = textOf(p, "status");
  return r;
}

CreateAssignmentRequest createAssignmentRequest(const RequestContext ctx, Json p) {
  CreateAssignmentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.policyId = PolicyId(textOf(p, "policyId"));
  r.principalType = textOf(p, "principalType");
  r.principalId = textOf(p, "principalId");
  r.validFrom = "validFrom" in p ? parseIsoTime(p["validFrom"]) : 0;
  r.validTo = "validTo" in p ? parseIsoTime(p["validTo"]) : 0;
  return r;
}

UpdateAssignmentRequest updateAssignmentRequest(const RequestContext ctx, string key, Json p) {
  UpdateAssignmentRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = PolicyAssignmentId(key);
  r.fields = fieldsOf(p);
  r.validFrom = "validFrom" in p ? parseIsoTime(p["validFrom"]) : 0;
  r.validTo = "validTo" in p ? parseIsoTime(p["validTo"]) : 0;
  return r;
}

EvaluateAuthorizationRequest evaluateRequest(const RequestContext ctx, Json p) {
  EvaluateAuthorizationRequest r;
  r.tenantId = tenantOf(ctx);
  r.principalId = textOf(p, "principalId");
  r.application = textOf(p, "application");
  r.resource = textOf(p, "resource");
  r.action = textOf(p, "action");
  r.groups = splitList(textOf(p, "groups"));
  r.attributes = parseAttributes(textOf(p, "attributes"));
  r.record = boolOf(p, "record", true);
  r.channel = ctx.channel;
  return r;
}
