/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model).
module uim.platform.authorization.presentation.odata.serializers;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
Json isoTime(long stdTime) @trusted {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime - stdTime % 10_000_000, UTC());
  return Json(t.toISOExtString);
}

/// ISO 8601 → std time (null / "" → 0).
long parseIsoTime(Json value) @trusted {
  if (value.type != Json.Type.string || value.get!string.strip.length == 0)
    return 0;
  try
    return SysTime.fromISOExtString(value.get!string.strip).stdTime;
  catch (Exception)
    throw AuthorizationException.invalid("Invalid timestamp '" ~ value.get!string ~ "' (expected ISO 8601)");
}

Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

Json applicationRow(const ManagedApplication e, size_t apis = 0, size_t policies = 0) {
  auto j = auditRow(e);
  j["name"] = e.name;
  j["organizationId"] = e.organizationId;
  j["description"] = e.description;
  j["apiCount"] = apis;
  j["policyCount"] = policies;
  return j;
}

Json apiRow(const ApplicationApi e, string applicationName = "") {
  auto j = auditRow(e);
  j["applicationId"] = e.applicationId.value;
  j["applicationName"] = applicationName;
  j["name"] = e.name;
  j["endpoint"] = e.endpoint;
  j["operations"] = textsJson(e.operations);
  return j;
}

Json policyRow(const AuthorizationPolicy e, string applicationName = "", size_t assignments = 0) {
  auto j = auditRow(e);
  j["applicationId"] = e.applicationId.value;
  j["applicationName"] = applicationName;
  j["name"] = e.name;
  j["description"] = e.description;
  j["resource"] = e.resource;
  j["action"] = e.action;
  j["conditions"] = conditionsText(e.conditions);
  j["kind"] = cast(string) e.kind;
  j["status"] = cast(string) e.status;
  j["assignmentCount"] = assignments;
  return j;
}

Json assignmentRow(const PolicyAssignment e, const AuthorizationPolicy policy, string applicationName = "") {
  auto j = auditRow(e);
  j["policyId"] = e.policyId.value;
  j["policyName"] = policy.name;
  j["applicationId"] = policy.applicationId.value;
  j["applicationName"] = applicationName;
  j["principalType"] = cast(string) e.principalType;
  j["principalId"] = e.principalId;
  j["validFrom"] = isoTime(e.validFrom);
  j["validTo"] = isoTime(e.validTo);
  j["effective"] = e.isEffective(nowStdTime()) && policy.isActive;
  return j;
}

Json decisionRow(const DecisionRecord e, string applicationName = "") {
  auto j = auditRow(e);
  j["principalId"] = e.principalId;
  j["groups"] = e.groups.join(", ");
  j["applicationId"] = e.applicationId.value;
  j["applicationName"] = applicationName;
  j["resource"] = e.resource;
  j["action"] = e.action;
  j["attributes"] = e.attributes;
  j["allowed"] = e.allowed;
  j["reason"] = e.reason;
  j["matchedPolicies"] = e.matchedPolicyIds.join(", ");
  j["channel"] = e.channel;
  return j;
}

Json statisticsRow(const AuthorizationStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId;
  static foreach (name; ["applications", "applicationApis", "policies", "basePolicies", "customPolicies",
      "disabledPolicies", "unassignedPolicies", "assignments", "userAssignments", "groupAssignments",
      "expiredAssignments", "principals", "decisions", "permittedDecisions", "deniedDecisions"])
    j[name] = __traits(getMember, s, name);
  j["lastDecisionAt"] = isoTime(s.lastDecisionAt);
  return j;
}

Json authorizationResultRow(const AuthorizationResult r) {
  auto j = Json.emptyObject;
  j["allowed"] = r.allowed;
  j["reason"] = r.reason;
  j["principalId"] = r.principalId;
  j["applicationId"] = r.applicationId.value;
  j["resource"] = r.resource;
  j["action"] = r.action;
  j["matchedPolicies"] = r.matchedPolicyNames.join(", ");
  j["matchedPolicyIds"] = r.matchedPolicyIds.join(", ");
  j["candidatePolicies"] = r.candidatePolicies;
  j["decisionId"] = r.decisionId.value;
  j["evaluatedAt"] = isoTime(r.evaluatedAt);
  return j;
}

Json actionResultRow(string id, string message, size_t count = 0, bool success = true) {
  auto j = Json.emptyObject;
  j["id"] = id;
  j["success"] = success;
  j["message"] = message;
  j["count"] = count;
  return j;
}
