/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads, access checks), Integrate (runs, validation,
/// deployment, schedules), Model (views, data flows, remote tables, data
/// access controls, catalog), Manage (spaces, members, connections, tasks,
/// task chains), Admin (Users). Timestamps are Edm.DateTimeOffset, sizes
/// GiB / MiB (Edm.Double).
module uim.platform.datasphere.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.datasphere";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// The space reference of a space-scoped set (immutable) and its name (computed).
private ODataEntitySetDef inSpace(ODataEntitySetDef set) {
  return set.property("spaceId", Edm.string_, "Space", false)
    .property("spaceName", Edm.string_, "Space Name")
    .computed("spaceName")
    .immutableProps("spaceId");
}

/// Schedule properties of tasks and task chains.
private ODataEntitySetDef scheduled(ODataEntitySetDef set) {
  return set.property("frequency", Edm.string_, "Frequency")
    .property("intervalMinutes", Edm.int32, "Interval (min)")
    .property("startAt", Edm.dateTimeOffset, "Start")
    .property("schedule", Edm.string_, "Schedule")
    .property("status", Edm.string_, "Schedule Status")
    .property("nextRunAt", Edm.dateTimeOffset, "Next Run")
    .property("lastRunStatus", Edm.string_, "Last Run")
    .property("lastRunAt", Edm.dateTimeOffset, "Last Run At")
    .property("lastRunDurationMs", Edm.int64, "Duration (ms)")
    .property("lastRunMessage", Edm.string_, "Last Message")
    .computed("schedule", "status", "nextRunAt", "lastRunStatus", "lastRunAt", "lastRunDurationMs", "lastRunMessage");
}

ODataServiceModel datasphereModel() {
  auto m = new ODataServiceModel(odataNamespace, "DatasphereService", "Datasphere");

  // ── spaces ──────────────────────────────────────────────────────────────
  audited(m.entitySet("Spaces", "Space")
      .property("id", Edm.string_, "Space", false)
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("status", Edm.string_, "Status")
      .property("priority", Edm.int32, "Priority")
      .property("diskQuotaGiB", Edm.double_, "Disk (GiB)")
      .property("memoryQuotaGiB", Edm.double_, "Memory (GiB)")
      .property("usedDiskGiB", Edm.double_, "Used Disk (GiB)")
      .property("diskUsagePercent", Edm.double_, "Disk Used (%)")
      .property("auditLogEnabled", Edm.boolean, "Audit Log")
      .property("lockedReason", Edm.string_, "Lock Reason")
      .property("memberCount", Edm.int32, "Members")
      .property("objectCount", Edm.int32, "Objects")
      .computed("status", "usedDiskGiB", "diskUsagePercent", "lockedReason", "memberCount", "objectCount"))
    .writable()
    .titled("Space", "Spaces", "name", "description")
    .columns("id", "name", "status", "priority", "usedDiskGiB", "diskQuotaGiB", "diskUsagePercent", "objectCount")
    .filters("status")
    .scopes(readScope, manageScope);

  audited(inSpace(m.entitySet("Members", "Member")
      .property("id", Edm.string_, "Member", false))
      .property("userName", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("role", Edm.string_, "Role")
      .immutableProps("userName"))
    .writable()
    .titled("Member", "Members", "userName", "role")
    .columns("userName", "displayName", "role", "spaceName")
    .filters("spaceId", "role")
    .scopes(readScope, manageScope);

  // ── data integration ────────────────────────────────────────────────────
  audited(inSpace(m.entitySet("Connections", "Connection")
      .property("id", Edm.string_, "Connection", false))
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("connectionType", Edm.string_, "Type")
      .property("host", Edm.string_, "Host")
      .property("port", Edm.int32, "Port")
      .property("database", Edm.string_, "Database")
      .property("user", Edm.string_, "User")
      .property("password", Edm.string_, "Password")
      .collection("properties", Edm.string_, "Properties")
      .property("endpoint", Edm.string_, "Endpoint")
      .property("hasPassword", Edm.boolean, "Password Set")
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("lastValidatedAt", Edm.dateTimeOffset, "Validated At")
      .property("remoteTableCount", Edm.int32, "Remote Tables")
      .computed("endpoint", "hasPassword", "status", "statusMessage", "lastValidatedAt", "remoteTableCount"))
    .writable()
    .titled("Connection", "Connections", "name", "endpoint")
    .columns("name", "connectionType", "endpoint", "status", "remoteTableCount", "spaceName")
    .filters("spaceId", "connectionType", "status")
    .scopes(readScope, manageScope);

  audited(inSpace(m.entitySet("RemoteTables", "RemoteTable")
      .property("id", Edm.string_, "Remote Table", false))
      .property("connectionId", Edm.string_, "Connection", false)
      .property("connectionName", Edm.string_, "Connection Name")
      .property("name", Edm.string_, "Technical Name", false)
      .property("businessName", Edm.string_, "Business Name")
      .property("description", Edm.string_, "Description")
      .property("remoteSchema", Edm.string_, "Remote Schema")
      .property("remoteObject", Edm.string_, "Remote Object", false)
      .property("replicationMode", Edm.string_, "Access")
      .property("replicationStatus", Edm.string_, "Replication")
      .collection("columns", Edm.string_, "Columns")
      .property("columnCount", Edm.int32, "Columns")
      .property("rowCount", Edm.int64, "Rows")
      .property("sizeMiB", Edm.double_, "Size (MiB)")
      .property("lastReplicatedAt", Edm.dateTimeOffset, "Replicated At")
      .property("lastMessage", Edm.string_, "Last Message")
      .computed("connectionName", "replicationStatus", "columnCount", "rowCount", "sizeMiB", "lastReplicatedAt", "lastMessage")
      .immutableProps("connectionId", "name"))
    .writable()
    .titled("Remote Table", "Remote Tables", "businessName", "name")
    .columns("name", "businessName", "connectionName", "replicationMode", "replicationStatus", "rowCount", "sizeMiB")
    .filters("spaceId", "connectionId", "replicationMode", "replicationStatus")
    .scopes(readScope, modelScope);

  // ── modeling ────────────────────────────────────────────────────────────
  audited(inSpace(m.entitySet("Views", "View")
      .property("id", Edm.string_, "View", false))
      .property("name", Edm.string_, "Technical Name", false)
      .property("businessName", Edm.string_, "Business Name")
      .property("description", Edm.string_, "Description")
      .property("semantic", Edm.string_, "Semantic Usage")
      .property("sqlExpression", Edm.string_, "SQL")
      .collection("sourceObjects", Edm.string_, "Sources")
      .property("sourcesText", Edm.string_, "Sources")
      .collection("columns", Edm.string_, "Columns")
      .property("columnCount", Edm.int32, "Columns")
      .property("exposed", Edm.boolean, "Exposed")
      .property("deploymentStatus", Edm.string_, "Deployment")
      .property("deployedAt", Edm.dateTimeOffset, "Deployed At")
      .property("persisted", Edm.boolean, "Persisted")
      .property("rowCount", Edm.int64, "Rows")
      .property("persistedMiB", Edm.double_, "Persisted (MiB)")
      .property("persistedAt", Edm.dateTimeOffset, "Persisted At")
      .property("lastRunStatus", Edm.string_, "Last Persistence")
      .property("lastRunMessage", Edm.string_, "Last Message")
      .property("protectedBy", Edm.int32, "Access Controls")
      .computed("sourceObjects", "sourcesText", "columnCount", "deploymentStatus", "deployedAt", "persisted", "rowCount",
        "persistedMiB", "persistedAt", "lastRunStatus", "lastRunMessage", "protectedBy")
      .immutableProps("name"))
    .writable()
    .titled("View", "Views", "businessName", "name")
    .columns("name", "businessName", "semantic", "deploymentStatus", "exposed", "persisted", "rowCount")
    .filters("spaceId", "semantic", "deploymentStatus", "exposed", "persisted")
    .scopes(readScope, modelScope);

  audited(inSpace(m.entitySet("DataFlows", "DataFlow")
      .property("id", Edm.string_, "Data Flow", false))
      .property("name", Edm.string_, "Technical Name", false)
      .property("businessName", Edm.string_, "Business Name")
      .property("description", Edm.string_, "Description")
      .collection("sourceObjects", Edm.string_, "Sources")
      .property("sourcesText", Edm.string_, "Sources")
      .collection("transforms", Edm.string_, "Transformations")
      .property("transformCount", Edm.int32, "Transformations")
      .property("targetTable", Edm.string_, "Target Table")
      .property("loadMode", Edm.string_, "Load Mode")
      .property("deploymentStatus", Edm.string_, "Deployment")
      .property("deployedAt", Edm.dateTimeOffset, "Deployed At")
      .property("lastRunStatus", Edm.string_, "Last Run")
      .property("lastRunAt", Edm.dateTimeOffset, "Last Run At")
      .property("lastRunDurationMs", Edm.int64, "Duration (ms)")
      .property("targetRows", Edm.int64, "Target Rows")
      .property("targetMiB", Edm.double_, "Target (MiB)")
      .property("lastRunMessage", Edm.string_, "Last Message")
      .computed("sourcesText", "transformCount", "deploymentStatus", "deployedAt", "lastRunStatus", "lastRunAt",
        "lastRunDurationMs", "targetRows", "targetMiB", "lastRunMessage")
      .immutableProps("name"))
    .writable()
    .titled("Data Flow", "Data Flows", "businessName", "name")
    .columns("name", "businessName", "sourcesText", "targetTable", "deploymentStatus", "lastRunStatus", "targetRows")
    .filters("spaceId", "deploymentStatus", "lastRunStatus", "loadMode")
    .scopes(readScope, modelScope);

  // ── scheduling and monitoring ───────────────────────────────────────────
  audited(scheduled(inSpace(m.entitySet("Tasks", "Task")
      .property("id", Edm.string_, "Task", false)))
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("taskType", Edm.string_, "Type")
      .property("targetObjectId", Edm.string_, "Object", false)
      .property("targetName", Edm.string_, "Object Name")
      .property("maxRetries", Edm.int32, "Retries")
      .property("consecutiveFailures", Edm.int32, "Failures in a Row")
      .computed("targetName", "consecutiveFailures")
      .immutableProps("taskType"))
    .writable()
    .titled("Task", "Tasks", "name", "targetName")
    .columns("name", "taskType", "targetName", "schedule", "status", "nextRunAt", "lastRunStatus")
    .filters("spaceId", "taskType", "status", "lastRunStatus", "frequency")
    .scopes(readScope, manageScope);

  audited(scheduled(inSpace(m.entitySet("TaskChains", "TaskChain")
      .property("id", Edm.string_, "Task Chain", false)))
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .collection("taskIds", Edm.string_, "Steps")
      .property("stepsText", Edm.string_, "Steps")
      .property("stepCount", Edm.int32, "Steps")
      .property("failurePolicy", Edm.string_, "On Failure")
      .computed("stepsText", "stepCount"))
    .writable()
    .titled("Task Chain", "Task Chains", "name", "stepsText")
    .columns("name", "stepCount", "failurePolicy", "schedule", "status", "nextRunAt", "lastRunStatus")
    .filters("spaceId", "status", "lastRunStatus")
    .scopes(readScope, manageScope);

  audited(inSpace(m.entitySet("Runs", "Run")
      .property("id", Edm.string_, "Run", false))
      .property("objectType", Edm.string_, "Type")
      .property("objectId", Edm.string_, "Object")
      .property("objectName", Edm.string_, "Object Name")
      .property("taskId", Edm.string_, "Task")
      .property("chainRunId", Edm.string_, "Chain Run")
      .property("trigger", Edm.string_, "Trigger")
      .property("status", Edm.string_, "Status")
      .property("attempts", Edm.int32, "Attempt")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("finishedAt", Edm.dateTimeOffset, "Finished At")
      .property("durationMs", Edm.int64, "Duration (ms)")
      .property("rowsProcessed", Edm.int64, "Rows")
      .property("sizeMiB", Edm.double_, "Size (MiB)")
      .property("message", Edm.string_, "Message"))
    .writable(false, false, false)
    .titled("Run", "Runs", "objectName", "message")
    .columns("startedAt", "objectType", "objectName", "trigger", "status", "durationMs", "rowsProcessed", "message")
    .filters("spaceId", "objectType", "objectId", "status", "trigger", "taskId", "chainRunId")
    .scopes(readScope, integrateScope);

  // ── governance ──────────────────────────────────────────────────────────
  audited(inSpace(m.entitySet("AccessControls", "AccessControl")
      .property("id", Edm.string_, "Data Access Control", false))
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("criteriaColumn", Edm.string_, "Criteria Column", false)
      .property("criteriaOperator", Edm.string_, "Operator")
      .collection("criteriaValues", Edm.string_, "Values")
      .property("criteriaText", Edm.string_, "Criteria")
      .collection("targetViewIds", Edm.string_, "Protected Views")
      .property("viewsText", Edm.string_, "Protected Views")
      .collection("assignedUsers", Edm.string_, "Users")
      .property("usersText", Edm.string_, "Users")
      .property("enabled", Edm.boolean, "Enabled")
      .computed("criteriaText", "viewsText", "usersText"))
    .writable()
    .titled("Data Access Control", "Data Access Controls", "name", "criteriaText")
    .columns("name", "criteriaText", "viewsText", "usersText", "enabled")
    .filters("spaceId", "enabled", "criteriaOperator")
    .scopes(readScope, modelScope);

  audited(inSpace(m.entitySet("CatalogAssets", "CatalogAsset")
      .property("id", Edm.string_, "Asset", false))
      .property("name", Edm.string_, "Name", false)
      .property("businessName", Edm.string_, "Business Name")
      .property("description", Edm.string_, "Description")
      .property("assetType", Edm.string_, "Type")
      .property("sourceObjectId", Edm.string_, "Object")
      .property("owner", Edm.string_, "Owner")
      .property("qualityStatus", Edm.string_, "Quality")
      .property("sensitivity", Edm.string_, "Sensitivity")
      .collection("tags", Edm.string_, "Tags")
      .property("tagsText", Edm.string_, "Tags")
      .collection("glossaryTerms", Edm.string_, "Glossary Terms")
      .property("termsText", Edm.string_, "Glossary Terms")
      .property("accessCount", Edm.int64, "Accesses")
      .property("lastAccessedAt", Edm.dateTimeOffset, "Last Access")
      .computed("tagsText", "termsText", "accessCount", "lastAccessedAt"))
    .writable()
    .titled("Catalog Asset", "Catalog", "businessName", "description")
    .columns("businessName", "name", "assetType", "owner", "qualityStatus", "sensitivity", "tagsText")
    .filters("spaceId", "assetType", "qualityStatus", "sensitivity", "owner")
    .scopes(readScope, modelScope);

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
  m.complexType("AccessDecision")
    .property("viewId", Edm.string_, "View")
    .property("user", Edm.string_, "User")
    .property("allowed", Edm.boolean, "Allowed")
    .property("protected", Edm.boolean, "Protected")
    .property("matchedControls", Edm.string_, "Granted By")
    .property("reason", Edm.string_, "Reason");
  m.complexType("SchedulerSummary")
    .property("due", Edm.int32, "Due")
    .property("started", Edm.int32, "Started")
    .property("completed", Edm.int32, "Completed")
    .property("failed", Edm.int32, "Failed")
    .property("skipped", Edm.int32, "Skipped")
    .property("summary", Edm.string_, "Summary")
    .property("messages", Edm.string_, "Messages");
  m.complexType("PurgeResult")
    .property("runs", Edm.int32, "Runs");
  auto seed = m.complexType("SeedResult");
  foreach (name; ["spaces", "members", "connections", "remoteTables", "views", "dataFlows", "tasks", "taskChains",
      "accessControls", "catalogAssets", "runs"])
    seed.property(name, Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("LockSpace", "Space").parameter("id", Edm.string_, false).parameter("reason", Edm.string_)
    .labelled("Lock Space").requires(manageScope);
  m.action("UnlockSpace", "Space").parameter("id", Edm.string_, false).labelled("Unlock Space").requires(manageScope);
  m.action("ValidateConnection", "Connection").parameter("id", Edm.string_, false).labelled("Validate")
    .requires(integrateScope);
  m.action("ReplicateRemoteTable", "Run").parameter("id", Edm.string_, false).labelled("Load New Snapshot")
    .requires(integrateScope);
  m.action("DropReplica", "RemoteTable").parameter("id", Edm.string_, false).labelled("Remove Replicated Data")
    .requires(integrateScope);
  m.action("DeployView", "View").parameter("id", Edm.string_, false).labelled("Deploy").requires(integrateScope);
  m.action("PersistView", "Run").parameter("id", Edm.string_, false).labelled("Persist").requires(integrateScope);
  m.action("RemovePersistence", "View").parameter("id", Edm.string_, false).labelled("Remove Persisted Data")
    .requires(integrateScope);
  m.action("CheckDataAccess", "AccessDecision").parameter("viewId", Edm.string_, false).parameter("user", Edm.string_, false)
    .parameter("row", Edm.string_, false).labelled("Check Row Access").requires(readScope);
  m.action("DeployDataFlow", "DataFlow").parameter("id", Edm.string_, false).labelled("Deploy").requires(integrateScope);
  m.action("RunDataFlow", "Run").parameter("id", Edm.string_, false).labelled("Run").requires(integrateScope);
  m.action("RunTask", "Run").parameter("id", Edm.string_, false).labelled("Run Now").requires(integrateScope);
  m.action("PauseTask", "Task").parameter("id", Edm.string_, false).labelled("Pause Schedule").requires(integrateScope);
  m.action("ResumeTask", "Task").parameter("id", Edm.string_, false).labelled("Resume Schedule").requires(integrateScope);
  m.action("RunTaskChain", "Run").parameter("id", Edm.string_, false).labelled("Run Now").requires(integrateScope);
  m.action("PauseTaskChain", "TaskChain").parameter("id", Edm.string_, false).labelled("Pause Schedule")
    .requires(integrateScope);
  m.action("ResumeTaskChain", "TaskChain").parameter("id", Edm.string_, false).labelled("Resume Schedule")
    .requires(integrateScope);
  m.action("RunDueSchedules", "SchedulerSummary").labelled("Run Due Schedules").requires(integrateScope);
  m.action("PurgeRuns", "PurgeResult").labelled("Purge Old Runs").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);
  return m;
}

/// Numeric members of the Statistics singleton (all of DspStatistics but the tenant).
enum string[] statisticNames = [
    "spaces", "lockedSpaces", "members", "connections", "validConnections", "remoteTables", "replicatedTables", "views",
    "deployedViews", "exposedViews", "dataFlows", "tasks", "scheduledTasks", "taskChains", "runsLast24h",
    "failedRunsLast24h", "accessControls", "catalogAssets", "usedDiskMiB", "diskQuotaMiB", "users"
  ];

/// "failedRunsLast24h" → "Failed Runs (24 h)", "usedDiskMiB" → "Used Disk (MiB)"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string suffix;
  foreach (unit; [["Last24h", " (24 h)"], ["MiB", " (MiB)"]])
    if (name.endsWith(unit[0])) {
      name = name[0 .. $ - unit[0].length];
      suffix = unit[1];
    }
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
  return label ~ suffix;
}

///
unittest {
  import std.traits : FieldNameTuple;

  auto m = datasphereModel();
  m.validate();
  assert(m.has("Spaces") && m.find("Statistics").singleton && m.find("Runs").key == "id");
  assert(!m.find("Runs").insertable && !m.find("Runs").updatable);
  assert(m.find("RemoteTables").propertyOf("connectionId").immutable_ && m.find("Views").propertyOf("deploymentStatus").computed);
  assert(m.find("Tasks").propertyOf("spaceId").immutable_);
  assert(m.findAction("RunDueSchedules").returnEdmType == "uim.datasphere.SchedulerSummary");
  assert(statisticLabel("failedRunsLast24h") == "Failed Runs (24 h)", statisticLabel("failedRunsLast24h"));
  assert(statisticLabel("usedDiskMiB") == "Used Disk (MiB)", statisticLabel("usedDiskMiB"));
  // the statistics model and the port agree
  string[] fields;
  static foreach (name; FieldNameTuple!DspStatistics)
    static if (name != "tenantId")
      fields ~= name;
  assert(fields == statisticNames, fields.to!string);
}
