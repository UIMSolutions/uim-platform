/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (everything but the administration), Operate (validate,
/// start / stop, playground, reconcile), Develop (scenarios, configurations,
/// registry, prompts), Manage (workspaces, connections, resource groups),
/// Admin (users, roles, audit log, tiles). Timestamps are
/// Edm.DateTimeOffset; list valued attributes are collections of strings
/// with a computed "…Text" companion for tables.
module uim.platform.ai_launchpad.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.ailaunchpad";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// A list valued attribute and its computed text form ("labels" + "labelsText").
private ODataEntitySetDef listed(ODataEntitySetDef set, string name, string label) {
  return set.collection(name, Edm.string_, label).property(name ~ "Text", Edm.string_, label).computed(name ~ "Text");
}

private ODataEntitySetDef tileProperties(ODataEntitySetDef set) {
  return set.property("title", Edm.string_, "Title", false)
    .property("subtitle", Edm.string_, "Subtitle")
    .property("info", Edm.string_, "Footer")
    .property("icon", Edm.string_, "Icon")
    .property("groupName", Edm.string_, "Group")
    .property("sortOrder", Edm.int32, "Order")
    .property("targetType", Edm.string_, "Target Type")
    .property("target", Edm.string_, "Target", false)
    .property("kpi", Edm.string_, "KPI")
    .property("kpiUnit", Edm.string_, "KPI Unit")
    .property("requiredScope", Edm.string_, "Required Scope");
}

ODataServiceModel launchpadModel() {
  auto m = new ODataServiceModel(odataNamespace, "AiLaunchpadService", "AI Launchpad");

  // ── runtimes ────────────────────────────────────────────────────────────
  audited(m.entitySet("Workspaces", "Workspace")
      .property("id", Edm.string_, "Workspace", false)
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("status", Edm.string_, "Status")
      .property("connectionCount", Edm.int32, "Connections")
      .property("promptCollectionCount", Edm.int32, "Prompt Collections")
      .computed("connectionCount", "promptCollectionCount"))
    .writable()
    .titled("Workspace", "Workspaces", "name", "description")
    .columns("id", "name", "status", "connectionCount", "promptCollectionCount")
    .filters("status")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Connections", "Connection")
      .property("id", Edm.string_, "Connection", false)
      .property("workspaceId", Edm.string_, "Workspace", false)
      .property("workspaceName", Edm.string_, "Workspace Name")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("connectionType", Edm.string_, "Type")
      .property("url", Edm.string_, "Service URL", false)
      .property("authUrl", Edm.string_, "Auth URL")
      .property("clientId", Edm.string_, "Client ID")
      .property("clientSecret", Edm.string_, "Client Secret")
      .property("hasSecret", Edm.boolean, "Secret Set")
      .property("defaultResourceGroup", Edm.string_, "Default Resource Group")
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("lastValidatedAt", Edm.dateTimeOffset, "Validated At")
      .property("resourceGroupCount", Edm.int32, "Resource Groups")
      .property("scenarioCount", Edm.int32, "Scenarios")
      .computed("workspaceName", "hasSecret", "status", "statusMessage", "lastValidatedAt", "resourceGroupCount",
        "scenarioCount")
      .immutableProps("workspaceId"))
    .writable()
    .titled("Connection", "Connections", "name", "url")
    .columns("name", "connectionType", "url", "status", "workspaceName", "scenarioCount")
    .filters("workspaceId", "connectionType", "status")
    .scopes(readScope, manageScope);

  audited(listed(m.entitySet("ResourceGroups", "ResourceGroup")
      .property("id", Edm.string_, "Resource Group", false)
      .property("connectionId", Edm.string_, "Connection", false)
      .property("connectionName", Edm.string_, "Connection Name")
      .property("description", Edm.string_, "Description"), "labels", "Labels")
      .property("status", Edm.string_, "Status")
      .property("activeExecutions", Edm.int32, "Active Executions")
      .property("activeDeployments", Edm.int32, "Active Deployments")
      .computed("connectionName", "activeExecutions", "activeDeployments")
      .immutableProps("connectionId"))
    .writable()
    .titled("Resource Group", "Resource Groups", "id", "description")
    .columns("id", "connectionName", "status", "labelsText", "activeExecutions", "activeDeployments")
    .filters("connectionId", "status")
    .scopes(readScope, manageScope);

  // ── ML life cycle ───────────────────────────────────────────────────────
  audited(listed(listed(m.entitySet("Scenarios", "Scenario")
      .property("id", Edm.string_, "Scenario", false)
      .property("connectionId", Edm.string_, "Connection", false)
      .property("connectionName", Edm.string_, "Connection Name")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description"), "executables", "Executables"), "labels", "Labels")
      .property("configurationCount", Edm.int32, "Configurations")
      .property("executionCount", Edm.int32, "Executions")
      .property("deploymentCount", Edm.int32, "Deployments")
      .property("modelCount", Edm.int32, "Models")
      .property("datasetCount", Edm.int32, "Datasets")
      .computed("connectionName", "configurationCount", "executionCount", "deploymentCount", "modelCount", "datasetCount")
      .immutableProps("connectionId"))
    .writable()
    .titled("Scenario", "Scenarios", "name", "description")
    .columns("name", "connectionName", "executablesText", "configurationCount", "executionCount", "deploymentCount")
    .filters("connectionId")
    .scopes(readScope, developScope);

  audited(listed(listed(m.entitySet("Configurations", "Configuration")
      .property("id", Edm.string_, "Configuration", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("connectionId", Edm.string_, "Connection")
      .property("name", Edm.string_, "Name")
      .property("executableId", Edm.string_, "Executable", false), "parameters", "Parameters"), "inputArtifacts",
      "Input Artifacts")
      .property("executionCount", Edm.int32, "Executions")
      .property("deploymentCount", Edm.int32, "Deployments")
      .property("inUse", Edm.boolean, "In Use")
      .computed("scenarioName", "connectionId", "executionCount", "deploymentCount", "inUse")
      .immutableProps("scenarioId"))
    .writable()
    .titled("Configuration", "Configurations", "name", "executableId")
    .columns("name", "scenarioName", "executableId", "parametersText", "executionCount", "deploymentCount")
    .filters("scenarioId", "executableId", "connectionId")
    .scopes(readScope, developScope);

  audited(m.entitySet("Executions", "Execution")
      .property("id", Edm.string_, "Execution", false)
      .property("configurationId", Edm.string_, "Configuration", false)
      .property("configurationName", Edm.string_, "Configuration Name")
      .property("scenarioId", Edm.string_, "Scenario")
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("connectionId", Edm.string_, "Connection")
      .property("resourceGroupId", Edm.string_, "Resource Group")
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Completed At")
      .property("durationSeconds", Edm.int64, "Duration (s)")
      .computed("configurationName", "scenarioId", "scenarioName", "connectionId", "status", "statusMessage", "startedAt",
        "completedAt", "durationSeconds")
      .immutableProps("configurationId", "resourceGroupId"))
    .writable(true, false, true)
    .titled("Execution", "Executions", "id", "statusMessage")
    .columns("id", "configurationName", "scenarioName", "resourceGroupId", "status", "startedAt", "durationSeconds")
    .filters("status", "scenarioId", "configurationId", "resourceGroupId", "connectionId")
    .scopes(readScope, operateScope);

  audited(m.entitySet("Deployments", "Deployment")
      .property("id", Edm.string_, "Deployment", false)
      .property("configurationId", Edm.string_, "Configuration", false)
      .property("configurationName", Edm.string_, "Configuration Name")
      .property("scenarioId", Edm.string_, "Scenario")
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("connectionId", Edm.string_, "Connection")
      .property("resourceGroupId", Edm.string_, "Resource Group")
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("deploymentUrl", Edm.string_, "Inference URL")
      .property("minReplicas", Edm.int32, "Min Replicas")
      .property("maxReplicas", Edm.int32, "Max Replicas")
      .property("ttlMinutes", Edm.int32, "TTL (min)")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("stoppedAt", Edm.dateTimeOffset, "Stopped At")
      .property("expiresAt", Edm.dateTimeOffset, "Expires At")
      .computed("configurationName", "scenarioId", "scenarioName", "connectionId", "status", "statusMessage",
        "deploymentUrl", "startedAt", "stoppedAt", "expiresAt")
      .immutableProps("configurationId", "resourceGroupId"))
    .writable()
    .titled("Deployment", "Deployments", "id", "deploymentUrl")
    .columns("id", "configurationName", "scenarioName", "status", "deploymentUrl", "maxReplicas", "startedAt")
    .filters("status", "scenarioId", "configurationId", "resourceGroupId", "connectionId")
    .scopes(readScope, operateScope);

  // ── registry ────────────────────────────────────────────────────────────
  audited(listed(m.entitySet("Models", "Model")
      .property("id", Edm.string_, "Model", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("executionId", Edm.string_, "Execution")
      .property("name", Edm.string_, "Name", false)
      .property("version", Edm.string_, "Version")
      .property("description", Edm.string_, "Description")
      .property("url", Edm.string_, "URL")
      .property("sizeMiB", Edm.double_, "Size (MiB)")
      .property("status", Edm.string_, "Status"), "labels", "Labels")
      .computed("scenarioName")
      .immutableProps("scenarioId", "executionId"))
    .writable()
    .titled("Model", "Models", "name", "version")
    .columns("name", "version", "scenarioName", "status", "sizeMiB", "executionId")
    .filters("scenarioId", "status", "executionId")
    .scopes(readScope, developScope);

  audited(listed(m.entitySet("Datasets", "Dataset")
      .property("id", Edm.string_, "Dataset", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("scenarioName", Edm.string_, "Scenario Name")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("url", Edm.string_, "URL", false)
      .property("sizeMiB", Edm.double_, "Size (MiB)")
      .property("status", Edm.string_, "Status"), "labels", "Labels")
      .computed("scenarioName")
      .immutableProps("scenarioId"))
    .writable()
    .titled("Dataset", "Datasets", "name", "url")
    .columns("name", "scenarioName", "url", "status", "sizeMiB")
    .filters("scenarioId", "status")
    .scopes(readScope, developScope);

  // ── generative AI hub ───────────────────────────────────────────────────
  audited(m.entitySet("PromptCollections", "PromptCollection")
      .property("id", Edm.string_, "Collection", false)
      .property("workspaceId", Edm.string_, "Workspace", false)
      .property("workspaceName", Edm.string_, "Workspace Name")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("promptCount", Edm.int32, "Prompts")
      .computed("workspaceName", "promptCount")
      .immutableProps("workspaceId"))
    .writable()
    .titled("Prompt Collection", "Prompt Collections", "name", "description")
    .columns("name", "workspaceName", "promptCount", "description")
    .filters("workspaceId")
    .scopes(readScope, developScope);

  audited(listed(m.entitySet("Prompts", "Prompt")
      .property("id", Edm.string_, "Prompt", false)
      .property("collectionId", Edm.string_, "Collection", false)
      .property("collectionName", Edm.string_, "Collection Name")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("modelName", Edm.string_, "Model")
      .property("modelVersion", Edm.string_, "Model Version")
      .property("systemMessage", Edm.string_, "System Message")
      .property("userMessage", Edm.string_, "User Message", false)
      .property("temperature", Edm.double_, "Temperature")
      .property("maxTokens", Edm.int32, "Max Tokens")
      .property("topP", Edm.double_, "Top P")
      .property("status", Edm.string_, "Status")
      .property("version", Edm.int32, "Version"), "inputParams", "Inputs")
      .property("lastOutput", Edm.string_, "Last Output")
      .property("lastRunAt", Edm.dateTimeOffset, "Last Run")
      .property("runCount", Edm.int32, "Runs")
      .computed("collectionName", "version", "inputParams", "lastOutput", "lastRunAt", "runCount")
      .immutableProps("collectionId"))
    .writable()
    .titled("Prompt", "Prompts", "name", "modelName")
    .columns("name", "collectionName", "modelName", "status", "version", "inputParamsText", "runCount")
    .filters("collectionId", "status", "modelName")
    .scopes(readScope, developScope);

  // ── launchpad ───────────────────────────────────────────────────────────
  audited(tileProperties(m.entitySet("Tiles", "Tile").property("id", Edm.string_, "Tile", false))
      .property("visible", Edm.boolean, "Visible"))
    .writable()
    .titled("Tile", "Tiles", "title", "subtitle")
    .columns("title", "groupName", "sortOrder", "target", "kpi", "requiredScope", "visible")
    .filters("groupName", "targetType", "visible", "requiredScope")
    .scopes(adminScope, adminScope);

  tileProperties(m.entitySet("LaunchpadTiles", "LaunchpadTile").property("id", Edm.string_, "Tile", false))
    .property("kpiValue", Edm.int64, "KPI Value")
    .computed("kpiValue")
    .writable(false, false, false)
    .titled("Tile", "Launchpad", "title", "subtitle")
    .columns("groupName", "title", "subtitle", "kpiValue")
    .filters("groupName")
    .scopes(readScope, adminScope);

  // ── administration ──────────────────────────────────────────────────────
  audited(listed(listed(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("email", Edm.string_, "E-Mail")
      .property("password", Edm.string_, "Password"), "roles", "Roles"), "scopes", "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopes", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "email", "rolesText", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  audited(listed(m.entitySet("Roles", "Role")
      .property("id", Edm.string_, "Role", false)
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description"), "scopes", "Scopes")
      .property("builtIn", Edm.boolean, "Built-in")
      .property("userCount", Edm.int32, "Users")
      .computed("builtIn", "userCount"))
    .writable()
    .titled("Role", "Roles", "name", "description")
    .columns("id", "name", "scopesText", "builtIn", "userCount")
    .filters("builtIn")
    .scopes(adminScope, adminScope);

  audited(m.entitySet("LogEntries", "LogEntry")
      .property("id", Edm.string_, "Entry", false)
      .property("category", Edm.string_, "Category")
      .property("severity", Edm.string_, "Severity")
      .property("eventType", Edm.string_, "Event")
      .property("subject", Edm.string_, "Subject")
      .property("actor", Edm.string_, "User")
      .property("message", Edm.string_, "Message")
      .property("details", Edm.string_, "Details"))
    .writable(false, false, false)
    .titled("Log Entry", "Audit Log", "message", "eventType")
    .columns("createdAt", "severity", "category", "eventType", "actor", "message")
    .filters("category", "severity", "eventType", "actor", "subject")
    .scopes(adminScope, adminScope);

  // ── statistics ──────────────────────────────────────────────────────────
  auto stats = m.singletonSet("Statistics", "Statistic").keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false);
  foreach (name; statisticNames)
    stats.property(name, Edm.int32, statisticLabel(name));
  stats.titled("Statistics", "Statistics", "tenantId").scopes(readScope, manageScope);

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("ReconcileSummary")
    .property("checked", Edm.int32, "Checked")
    .property("started", Edm.int32, "Started")
    .property("completed", Edm.int32, "Completed")
    .property("failed", Edm.int32, "Failed")
    .property("deployed", Edm.int32, "Deployed")
    .property("dead", Edm.int32, "Dead")
    .property("expired", Edm.int32, "Expired")
    .property("summary", Edm.string_, "Summary")
    .property("messages", Edm.string_, "Messages");
  m.complexType("PromptRunResult")
    .property("promptId", Edm.string_, "Prompt")
    .property("promptVersion", Edm.int32, "Version")
    .property("modelName", Edm.string_, "Model")
    .property("renderedPrompt", Edm.string_, "Prompt")
    .property("output", Edm.string_, "Output")
    .property("promptTokens", Edm.int32, "Prompt Tokens")
    .property("completionTokens", Edm.int32, "Completion Tokens")
    .property("latencyMs", Edm.int64, "Latency (ms)");
  m.complexType("PurgeResult").property("entries", Edm.int32, "Entries");
  m.complexType("TileResult").property("tiles", Edm.int32, "Tiles");
  auto seed = m.complexType("SeedResult");
  foreach (name; seedResultNames)
    seed.property(name, Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("ValidateConnection", "Connection").parameter("id", Edm.string_, false).labelled("Validate")
    .requires(operateScope);
  m.action("StopExecution", "Execution").parameter("id", Edm.string_, false).labelled("Stop").requires(operateScope);
  m.action("StopDeployment", "Deployment").parameter("id", Edm.string_, false).labelled("Stop").requires(operateScope);
  m.action("StartDeployment", "Deployment").parameter("id", Edm.string_, false).labelled("Start").requires(operateScope);
  m.action("RunPrompt", "PromptRunResult").parameter("id", Edm.string_, false).parameter("inputs", Edm.string_)
    .labelled("Run").requires(operateScope);
  m.action("Reconcile", "ReconcileSummary").labelled("Synchronize with Runtime").requires(operateScope);
  m.action("PurgeLogs", "PurgeResult").labelled("Purge Old Entries").requires(adminScope);
  m.action("RestoreDefaultTiles", "TileResult").labelled("Restore Default Tiles").requires(adminScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);
  return m;
}

/// Members of SeedResult.
enum string[] seedResultNames = [
    "workspaces", "connections", "resourceGroups", "scenarios", "configurations", "executions", "deployments", "models",
    "datasets", "promptCollections", "prompts"
  ];

/// "runningExecutions" → "Running Executions", "warningsLast24h" → "Warnings (24 h)"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string suffix;
  if (name.endsWith("Last24h")) {
    name = name[0 .. $ - "Last24h".length];
    suffix = " (24 h)";
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

  auto m = launchpadModel();
  m.validate();
  assert(m.has("Executions") && m.find("Statistics").singleton && m.find("LogEntries").key == "id");
  assert(!m.find("LogEntries").insertable && !m.find("LaunchpadTiles").updatable && !m.find("Executions").updatable);
  assert(m.find("Connections").propertyOf("workspaceId").immutable_ && m.find("Deployments").propertyOf("status").computed);
  assert(m.findAction("RunPrompt").returnEdmType == "uim.ailaunchpad.PromptRunResult");
  assert(statisticLabel("warningsLast24h") == "Warnings (24 h)" && statisticLabel("runningExecutions") == "Running Executions");
  string[] fields;
  static foreach (name; FieldNameTuple!SeedResult)
    fields ~= name;
  assert(fields == seedResultNames, fields.to!string);
}
