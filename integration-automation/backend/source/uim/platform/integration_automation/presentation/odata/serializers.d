/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, counts, readiness) are passed in by the
/// engine, which computes them once per request.
module uim.platform.integration_automation.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// ISO 8601 date-time (seconds, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional values and references).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

Json systemRow(const SystemConnection s, long destinations = 0, long openWorkflows = 0) {
  auto j = auditRow(s);
  j["name"] = s.name;
  j["description"] = s.description;
  j["systemType"] = cast(string) s.systemType;
  j["host"] = s.host;
  j["port"] = s.port;
  j["protocol"] = s.protocol;
  j["client"] = s.client;
  j["sid"] = s.sid;
  j["environment"] = cast(string) s.environment;
  j["region"] = s.region;
  j["status"] = cast(string) s.status;
  j["lastTestedAt"] = isoTime(s.lastTestedAt);
  j["lastTestMessage"] = s.lastTestMessage;
  j["destinationCount"] = destinations;
  j["openWorkflowCount"] = openWorkflows;
  return j;
}

Json destinationRow(const Destination d, string systemName = "", long templates = 0) {
  auto j = auditRow(d);
  j["name"] = d.name;
  j["description"] = d.description;
  j["systemId"] = textOrNull(d.systemId.value);
  j["systemName"] = systemName;
  j["destinationType"] = cast(string) d.destinationType;
  j["url"] = d.url;
  j["authentication"] = cast(string) d.authentication;
  j["proxyType"] = cast(string) d.proxyType;
  j["locationId"] = d.locationId;
  j["user"] = d.user;
  j["tokenServiceUrl"] = d.tokenServiceUrl;
  j["audience"] = d.audience;
  j["scope"] = d.scope_;
  j["enabled"] = d.enabled;
  j["authorizationVariable"] = d.authentication == AuthenticationType.noAuthentication ? ""
    : destinationAuthorizationVariable(d.name);
  j["templateCount"] = templates;
  return j;
}

/// Counts of a scenario (computed by the engine).
struct ScenarioFacts {
  long tasks;
  long workflows;
  long openWorkflows;
  long estimatedMinutes;
}

Json scenarioRow(const IntegrationScenario s, ScenarioFacts f = ScenarioFacts.init) {
  auto j = auditRow(s);
  j["name"] = s.name;
  j["description"] = s.description;
  j["category"] = cast(string) s.category;
  j["version"] = s.version_;
  j["status"] = cast(string) s.status;
  j["sourceSystemType"] = cast(string) s.sourceSystemType;
  j["targetSystemType"] = cast(string) s.targetSystemType;
  j["prerequisites"] = texts(s.prerequisites);
  j["prerequisitesText"] = s.prerequisites.join("; ");
  j["basedOnId"] = textOrNull(s.basedOnId.value);
  j["activatedAt"] = isoTime(s.activatedAt);
  j["taskCount"] = f.tasks;
  j["workflowCount"] = f.workflows;
  j["openWorkflowCount"] = f.openWorkflows;
  j["estimatedMinutes"] = f.estimatedMinutes;
  return j;
}

Json scenarioTaskRow(const ScenarioTask t, string dependenciesText = "") {
  auto j = auditRow(t);
  j["scenarioId"] = t.scenarioId.value;
  j["sequenceNumber"] = t.sequenceNumber;
  j["name"] = t.name;
  j["description"] = t.description;
  j["taskType"] = cast(string) t.taskType;
  j["priority"] = cast(string) t.priority;
  j["assignedRole"] = t.assignedRole;
  j["instructions"] = t.instructions;
  j["destinationId"] = textOrNull(t.destinationId.value);
  j["automationEndpoint"] = t.automationEndpoint;
  j["automationPayload"] = t.automationPayload;
  j["requiresSourceSystem"] = t.requiresSourceSystem;
  j["requiresTargetSystem"] = t.requiresTargetSystem;
  j["afterPrevious"] = t.afterPrevious;
  j["dependsOn"] = texts(t.dependsOn);
  j["dependenciesText"] = dependenciesText;
  j["estimatedMinutes"] = t.estimatedMinutes;
  return j;
}

/// Names of the resources a workflow refers to (computed by the engine).
struct WorkflowNames {
  string scenario;
  string source;
  string target;
  string currentTask;
}

Json workflowRow(const Workflow w, WorkflowNames n = WorkflowNames.init) {
  auto j = auditRow(w);
  j["scenarioId"] = w.scenarioId.value;
  j["scenarioName"] = n.scenario;
  j["scenarioVersion"] = w.scenarioVersion;
  j["name"] = w.name;
  j["description"] = w.description;
  j["status"] = cast(string) w.status;
  j["sourceSystemId"] = textOrNull(w.sourceSystemId.value);
  j["sourceSystemName"] = n.source;
  j["targetSystemId"] = textOrNull(w.targetSystemId.value);
  j["targetSystemName"] = n.target;
  j["totalTasks"] = w.totalTasks;
  j["completedTasks"] = w.completedTasks;
  j["failedTasks"] = w.failedTasks;
  j["progressPercent"] = w.progressPercent;
  j["currentTaskId"] = textOrNull(w.currentTaskId.value);
  j["currentTaskName"] = n.currentTask;
  j["startedAt"] = isoTime(w.startedAt);
  j["completedAt"] = isoTime(w.completedAt);
  j["terminationReason"] = w.terminationReason;
  return j;
}

/// Derived facts of a task (computed by the engine from its workflow).
struct TaskFacts {
  string workflowName;
  string workflowStatus;
  bool ready;
  string waitingFor;
}

Json workflowTaskRow(const WorkflowTask t, TaskFacts f = TaskFacts.init) {
  auto j = auditRow(t);
  j["workflowId"] = t.workflowId.value;
  j["workflowName"] = f.workflowName;
  j["workflowStatus"] = f.workflowStatus;
  j["templateId"] = textOrNull(t.templateId.value);
  j["sequenceNumber"] = t.sequenceNumber;
  j["name"] = t.name;
  j["description"] = t.description;
  j["taskType"] = cast(string) t.taskType;
  j["status"] = cast(string) t.status;
  j["priority"] = cast(string) t.priority;
  j["assignedTo"] = t.assignedTo;
  j["assignedRole"] = t.assignedRole;
  j["instructions"] = t.instructions;
  j["destinationId"] = textOrNull(t.destinationId.value);
  j["automationEndpoint"] = t.automationEndpoint;
  j["sourceSystemId"] = textOrNull(t.sourceSystemId.value);
  j["targetSystemId"] = textOrNull(t.targetSystemId.value);
  j["dependsOn"] = texts(t.dependsOn);
  j["ready"] = f.ready;
  j["waitingFor"] = f.waitingFor;
  j["result"] = t.result;
  j["errorMessage"] = t.errorMessage;
  j["processedBy"] = t.processedBy;
  j["attempts"] = t.attempts;
  j["estimatedMinutes"] = t.estimatedMinutes;
  j["startedAt"] = isoTime(t.startedAt);
  j["completedAt"] = isoTime(t.completedAt);
  auto seconds = t.durationMs / 1000;
  j["durationSeconds"] = seconds > int.max ? int.max : seconds;
  return j;
}

Json executionLogRow(const ExecutionLog l) {
  auto j = auditRow(l);
  j["workflowId"] = textOrNull(l.workflowId.value);
  j["taskId"] = textOrNull(l.taskId.value);
  j["action"] = l.action;
  j["outcome"] = cast(string) l.outcome;
  j["message"] = l.message;
  j["details"] = l.details;
  j["executedBy"] = l.executedBy;
  j["durationMs"] = l.durationMs > int.max ? int.max : l.durationMs;
  return j;
}

Json userRow(const UserAccount u, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["password"] = Json(null);
  j["scopes"] = texts(u.scopes);
  j["scopesText"] = u.scopes.join(", ");
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json statisticsRow(const IaStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!IaStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

Json automationRunRow(const AutomationRunSummary s) {
  auto j = Json.emptyObject;
  j["workflows"] = s.workflows;
  j["executed"] = s.executed;
  j["succeeded"] = s.succeeded;
  j["failed"] = s.failed;
  j["notified"] = s.notified;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json seedRow(const SeedResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}
