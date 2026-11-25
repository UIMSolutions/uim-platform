/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads), Execute (workflows, tasks), Manage (landscape,
/// scenarios), Admin (Users). Timestamps are Edm.DateTimeOffset.
module uim.platform.integration_automation.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.integrationautomation";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

ODataServiceModel integrationAutomationModel() {
  auto m = new ODataServiceModel(odataNamespace, "IntegrationAutomationService", "Integration Automation");

  // ── landscape ───────────────────────────────────────────────────────────
  audited(m.entitySet("Systems", "System")
      .property("id", Edm.string_, "System", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("systemType", Edm.string_, "System Type")
      .property("host", Edm.string_, "Host", false)
      .property("port", Edm.int32, "Port")
      .property("protocol", Edm.string_, "Protocol")
      .property("client", Edm.string_, "Client")
      .property("sid", Edm.string_, "SID")
      .property("environment", Edm.string_, "Environment")
      .property("region", Edm.string_, "Region")
      .property("status", Edm.string_, "Connection")
      .property("lastTestedAt", Edm.dateTimeOffset, "Last Tested")
      .property("lastTestMessage", Edm.string_, "Last Test Result")
      .property("destinationCount", Edm.int32, "Destinations")
      .property("openWorkflowCount", Edm.int32, "Open Workflows")
      .computed("status", "lastTestedAt", "lastTestMessage", "destinationCount", "openWorkflowCount"))
    .writable()
    .titled("System", "Systems", "name", "host")
    .columns("name", "id", "systemType", "environment", "host", "status")
    .filters("systemType", "environment", "status")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Destinations", "Destination")
      .property("id", Edm.string_, "Destination", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("systemId", Edm.string_, "System")
      .property("systemName", Edm.string_, "System Name")
      .property("destinationType", Edm.string_, "Type")
      .property("url", Edm.string_, "URL")
      .property("authentication", Edm.string_, "Authentication")
      .property("proxyType", Edm.string_, "Proxy Type")
      .property("locationId", Edm.string_, "Location ID")
      .property("user", Edm.string_, "User")
      .property("tokenServiceUrl", Edm.string_, "Token Service URL")
      .property("audience", Edm.string_, "Audience")
      .property("scope", Edm.string_, "Scope")
      .property("enabled", Edm.boolean, "Enabled")
      .property("authorizationVariable", Edm.string_, "Credential Variable")
      .property("templateCount", Edm.int32, "Used by Task Templates")
      .computed("systemName", "authorizationVariable", "templateCount"))
    .writable()
    .titled("Destination", "Destinations", "name", "url")
    .columns("name", "destinationType", "url", "authentication", "proxyType", "enabled")
    .filters("destinationType", "authentication", "proxyType", "systemId", "enabled")
    .scopes(readScope, manageScope);

  // ── scenarios ───────────────────────────────────────────────────────────
  audited(m.entitySet("Scenarios", "Scenario")
      .property("id", Edm.string_, "Scenario", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("category", Edm.string_, "Category")
      .property("version", Edm.string_, "Version")
      .property("status", Edm.string_, "Status")
      .property("sourceSystemType", Edm.string_, "Source System Type")
      .property("targetSystemType", Edm.string_, "Target System Type")
      .collection("prerequisites", Edm.string_, "Prerequisites")
      .property("prerequisitesText", Edm.string_, "Prerequisites")
      .property("basedOnId", Edm.string_, "Based On")
      .property("activatedAt", Edm.dateTimeOffset, "Activated At")
      .property("taskCount", Edm.int32, "Task Templates")
      .property("workflowCount", Edm.int32, "Workflows")
      .property("openWorkflowCount", Edm.int32, "Open Workflows")
      .property("estimatedMinutes", Edm.int32, "Estimated Minutes")
      .computed("status", "prerequisitesText", "basedOnId", "activatedAt", "taskCount", "workflowCount",
        "openWorkflowCount", "estimatedMinutes"))
    .writable()
    .titled("Scenario", "Scenarios", "name", "description")
    .columns("name", "category", "version", "status", "taskCount", "workflowCount")
    .filters("category", "status", "sourceSystemType", "targetSystemType")
    .scopes(readScope, manageScope);

  audited(m.entitySet("ScenarioTasks", "ScenarioTask")
      .property("id", Edm.string_, "Task Template", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("sequenceNumber", Edm.int32, "Sequence")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("taskType", Edm.string_, "Type")
      .property("priority", Edm.string_, "Priority")
      .property("assignedRole", Edm.string_, "Role")
      .property("instructions", Edm.string_, "Instructions")
      .property("destinationId", Edm.string_, "Destination")
      .property("automationEndpoint", Edm.string_, "Endpoint")
      .property("automationPayload", Edm.string_, "Payload")
      .property("requiresSourceSystem", Edm.boolean, "Needs Source System")
      .property("requiresTargetSystem", Edm.boolean, "Needs Target System")
      .property("afterPrevious", Edm.boolean, "After Previous")
      .collection("dependsOn", Edm.string_, "Depends On")
      .property("dependenciesText", Edm.string_, "Dependencies")
      .property("estimatedMinutes", Edm.int32, "Estimated Minutes")
      .computed("dependenciesText")
      .immutableProps("scenarioId"))
    .writable()
    .titled("Task Template", "Task Templates", "name", "taskType")
    .columns("sequenceNumber", "name", "taskType", "assignedRole", "priority", "dependenciesText")
    .filters("scenarioId", "taskType", "priority")
    .scopes(readScope, manageScope);

  // ── execution ───────────────────────────────────────────────────────────
  audited(m.entitySet("Workflows", "Workflow")
      .property("id", Edm.string_, "Workflow", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("scenarioVersion", Edm.string_, "Scenario Version")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("status", Edm.string_, "Status")
      .property("sourceSystemId", Edm.string_, "Source System")
      .property("sourceSystemName", Edm.string_, "Source System Name")
      .property("targetSystemId", Edm.string_, "Target System")
      .property("targetSystemName", Edm.string_, "Target System Name")
      .property("totalTasks", Edm.int32, "Tasks")
      .property("completedTasks", Edm.int32, "Done")
      .property("failedTasks", Edm.int32, "Failed")
      .property("progressPercent", Edm.int32, "Progress")
      .property("currentTaskId", Edm.string_, "Current Task")
      .property("currentTaskName", Edm.string_, "Current Task Name")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Finished At")
      .property("terminationReason", Edm.string_, "Termination Reason")
      .computed("scenarioName", "scenarioVersion", "status", "sourceSystemName", "targetSystemName", "totalTasks",
        "completedTasks", "failedTasks", "progressPercent", "currentTaskId", "currentTaskName", "startedAt",
        "completedAt", "terminationReason")
      .immutableProps("scenarioId", "sourceSystemId", "targetSystemId"))
    .writable()
    .titled("Workflow", "Workflows", "name", "scenarioName")
    .columns("name", "scenarioName", "status", "progressPercent", "currentTaskName", "startedAt")
    .filters("scenarioId", "status", "sourceSystemId", "targetSystemId")
    .scopes(readScope, executeScope);

  audited(m.entitySet("WorkflowTasks", "WorkflowTask")
      .property("id", Edm.string_, "Task", false)
      .property("workflowId", Edm.string_, "Workflow")
      .property("workflowName", Edm.string_, "Workflow Name")
      .property("workflowStatus", Edm.string_, "Workflow Status")
      .property("templateId", Edm.string_, "Task Template")
      .property("sequenceNumber", Edm.int32, "Sequence")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("taskType", Edm.string_, "Type")
      .property("status", Edm.string_, "Status")
      .property("priority", Edm.string_, "Priority")
      .property("assignedTo", Edm.string_, "Assigned To")
      .property("assignedRole", Edm.string_, "Role")
      .property("instructions", Edm.string_, "Instructions")
      .property("destinationId", Edm.string_, "Destination")
      .property("automationEndpoint", Edm.string_, "Endpoint")
      .property("sourceSystemId", Edm.string_, "Source System")
      .property("targetSystemId", Edm.string_, "Target System")
      .collection("dependsOn", Edm.string_, "Depends On")
      .property("ready", Edm.boolean, "Ready")
      .property("waitingFor", Edm.string_, "Waiting For")
      .property("result", Edm.string_, "Result")
      .property("errorMessage", Edm.string_, "Error")
      .property("processedBy", Edm.string_, "Processed By")
      .property("attempts", Edm.int32, "Attempts")
      .property("estimatedMinutes", Edm.int32, "Estimated Minutes")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Finished At")
      .property("durationSeconds", Edm.int32, "Duration (s)")
      .computed("workflowId", "workflowName", "workflowStatus", "templateId", "sequenceNumber", "name", "description",
        "taskType", "status", "assignedRole", "instructions", "destinationId", "automationEndpoint", "sourceSystemId",
        "targetSystemId", "dependsOn", "ready", "waitingFor", "result", "errorMessage", "processedBy", "attempts",
        "estimatedMinutes", "startedAt", "completedAt", "durationSeconds"))
    .writable(false, true, false)
    .titled("Task", "Tasks", "name", "workflowName")
    .columns("sequenceNumber", "name", "taskType", "status", "assignedTo", "priority")
    .filters("workflowId", "status", "taskType", "assignedTo", "assignedRole", "ready")
    .scopes(readScope, executeScope);

  audited(m.entitySet("ExecutionLogs", "ExecutionLog")
      .property("id", Edm.string_, "Entry", false)
      .property("workflowId", Edm.string_, "Workflow")
      .property("taskId", Edm.string_, "Task")
      .property("action", Edm.string_, "Action")
      .property("outcome", Edm.string_, "Outcome")
      .property("message", Edm.string_, "Message")
      .property("details", Edm.string_, "Details")
      .property("executedBy", Edm.string_, "Executed By")
      .property("durationMs", Edm.int32, "Duration (ms)"))
    .titled("Log Entry", "Execution Log", "action", "message")
    .columns("createdAt", "action", "outcome", "message", "executedBy")
    .filters("workflowId", "taskId", "action", "outcome", "executedBy")
    .scopes(readScope, manageScope);

  // ── built-in login ──────────────────────────────────────────────────────
  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password")
      .collection("scopes", Edm.string_, "Scopes")
      .property("scopesText", Edm.string_, "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopesText", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  // ── statistics ──────────────────────────────────────────────────────────
  auto stats = m.singletonSet("Statistics", "Statistic").keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false);
  foreach (name; statisticNames)
    stats.property(name, Edm.int32, statisticLabel(name));
  stats.titled("Statistics", "Statistics", "tenantId").scopes(readScope, manageScope);

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("AutomationRunResult")
    .property("workflows", Edm.int32, "Workflows")
    .property("executed", Edm.int32, "Executed")
    .property("succeeded", Edm.int32, "Succeeded")
    .property("failed", Edm.int32, "Failed")
    .property("notified", Edm.int32, "Notified")
    .property("messages", Edm.string_, "Messages");
  m.complexType("PurgeResult").property("removed", Edm.int32, "Removed").property("olderThanDays", Edm.int32, "Days");
  m.complexType("SeedResult")
    .property("systems", Edm.int32)
    .property("destinations", Edm.int32)
    .property("scenarios", Edm.int32)
    .property("scenarioTasks", Edm.int32)
    .property("workflows", Edm.int32)
    .property("workflowTasks", Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("TestSystemConnection", "System").parameter("id", Edm.string_, false)
    .labelled("Test Connection").requires(manageScope);
  foreach (verb; ["Activate", "Deprecate", "Archive"])
    m.action(verb ~ "Scenario", "Scenario").parameter("id", Edm.string_, false).labelled(verb).requires(manageScope);
  m.action("CopyScenario", "Scenario").parameter("id", Edm.string_, false).parameter("newId", Edm.string_)
    .labelled("Copy as New Version").requires(manageScope);
  foreach (verb; ["Start", "Suspend", "Resume"])
    m.action(verb ~ "Workflow", "Workflow").parameter("id", Edm.string_, false).labelled(verb).requires(executeScope);
  m.action("TerminateWorkflow", "Workflow").parameter("id", Edm.string_, false).parameter("reason", Edm.string_)
    .labelled("Terminate").requires(executeScope);
  m.action("StartTask", "WorkflowTask").parameter("id", Edm.string_, false).labelled("Start").requires(executeScope);
  m.action("CompleteTask", "WorkflowTask").parameter("id", Edm.string_, false).parameter("result", Edm.string_)
    .labelled("Complete / Approve").requires(executeScope);
  m.action("FailTask", "WorkflowTask").parameter("id", Edm.string_, false).parameter("errorMessage", Edm.string_, false)
    .labelled("Fail / Reject").requires(executeScope);
  m.action("SkipTask", "WorkflowTask").parameter("id", Edm.string_, false).parameter("reason", Edm.string_, false)
    .labelled("Skip").requires(executeScope);
  m.action("RetryTask", "WorkflowTask").parameter("id", Edm.string_, false).labelled("Retry").requires(executeScope);
  m.action("AssignTask", "WorkflowTask").parameter("id", Edm.string_, false).parameter("assignedTo", Edm.string_)
    .parameter("priority", Edm.string_).labelled("Assign").requires(executeScope);
  m.action("RunAutomatedTasks", "AutomationRunResult").parameter("workflowId", Edm.string_)
    .labelled("Run Automated Tasks").requires(executeScope);
  m.action("PurgeExecutionLogs", "PurgeResult").parameter("olderThanDays", Edm.int32, false)
    .labelled("Purge Execution Log").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);
  return m;
}

/// Numeric members of the Statistics singleton (all of IaStatistics but the tenant).
enum string[] statisticNames = [
    "systems", "reachableSystems", "unreachableSystems", "destinations", "scenarios", "activeScenarios",
    "draftScenarios", "workflows", "openWorkflows", "maxOpenWorkflows", "runningWorkflows", "suspendedWorkflows",
    "failedWorkflows", "completedWorkflows", "tasks", "openTasks", "readyTasks", "myOpenTasks", "failedTasks",
    "automatedTasks", "executionLogs", "failuresLast24h", "completionRate"
  ];

/// "openWorkflows" → "Open Workflows"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string label;
  foreach (i, dchar c; name) {
    if (i == 0)
      label ~= toUpper(c);
    else {
      if (isUpper(c))
        label ~= ' ';
      label ~= c;
    }
  }
  return label.replace("Last24h", "(24 h)").replace("Last24 h", "(24 h)");
}

///
unittest {
  import std.traits : FieldNameTuple;

  auto m = integrationAutomationModel();
  m.validate();
  assert(m.has("Workflows") && m.find("Statistics").singleton && m.find("ExecutionLogs").key == "id");
  assert(!m.find("WorkflowTasks").insertable && m.find("WorkflowTasks").updatable);
  assert(!m.find("ExecutionLogs").insertable && !m.find("ExecutionLogs").updatable);
  assert(m.find("ScenarioTasks").propertyOf("scenarioId").immutable_ && m.find("Workflows").propertyOf("status").computed);
  assert(m.findAction("RunAutomatedTasks").returnEdmType == "uim.integrationautomation.AutomationRunResult");
  assert(statisticLabel("openWorkflows") == "Open Workflows");
  // the statistics model and the port agree
  string[] fields;
  static foreach (name; FieldNameTuple!IaStatistics)
    static if (name != "tenantId")
      fields ~= name;
  assert(fields == statisticNames, fields.to!string);
}
