/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the CLI and
/// the GtkD GUI.
///
/// Everything inside a resource group has the composite key
/// "<resourceGroupId>~<id>" (property "key"); "id" and "resourceGroupId" are
/// exposed separately for filtering. Labels and bindings are collections of
/// "key=value" strings. Scopes: Read (reads), Manage (writes, actions).
module uim.platform.ai_core.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.aicore";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// Composite key, id and resource group of group scoped sets.
private ODataEntitySetDef grouped(ODataEntitySetDef set, string idLabel = "ID") {
  return set.property("key", Edm.string_, "Key", false)
    .keyed("key")
    .property("id", Edm.string_, idLabel)
    .property("resourceGroupId", Edm.string_, "Resource Group", false)
    .computed("key")
    .immutableProps("id", "resourceGroupId");
}

ODataServiceModel aiCoreModel() {
  auto m = new ODataServiceModel(odataNamespace, "AiCoreService", "AI Core");

  audited(m.entitySet("ResourceGroups", "ResourceGroup")
      .property("id", Edm.string_, "Resource Group", false)
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .collection("labels", Edm.string_, "Labels")
      .property("scenarioCount", Edm.int32, "Scenarios")
      .property("executionCount", Edm.int32, "Executions")
      .property("deploymentCount", Edm.int32, "Deployments")
      .computed("status", "statusMessage", "scenarioCount", "executionCount", "deploymentCount"))
    .writable()
    .titled("Resource Group", "Resource Groups", "id", "status")
    .columns("id", "status", "scenarioCount", "executionCount", "deploymentCount")
    .filters("status")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Scenarios", "Scenario"), "Scenario ID")
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .collection("labels", Edm.string_, "Labels")
      .property("executableCount", Edm.int32, "Executables")
      .property("configurationCount", Edm.int32, "Configurations")
      .property("artifactCount", Edm.int32, "Artifacts")
      .computed("executableCount", "configurationCount", "artifactCount"))
    .writable()
    .titled("Scenario", "Scenarios", "name", "description")
    .columns("name", "id", "resourceGroupId", "executableCount", "configurationCount", "artifactCount")
    .filters("resourceGroupId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Executables", "Executable"), "Executable ID")
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("type", Edm.string_, "Type")
      .property("versionId", Edm.string_, "Version")
      .property("deployable", Edm.boolean, "Deployable")
      .collection("parameters", Edm.string_, "Parameters (key=default)")
      .collection("inputArtifacts", Edm.string_, "Input Artifacts (key:kind)")
      .collection("outputArtifacts", Edm.string_, "Output Artifacts (key:kind)")
      .collection("labels", Edm.string_, "Labels")
      .computed("deployable")
      .immutableProps("scenarioId", "type"))
    .writable()
    .titled("Executable", "Executables", "name", "id")
    .columns("name", "id", "scenarioId", "type", "versionId", "resourceGroupId")
    .filters("resourceGroupId", "scenarioId", "type")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Configurations", "Configuration"), "Configuration ID")
      .property("name", Edm.string_, "Name", false)
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("executableId", Edm.string_, "Executable", false)
      .property("executableType", Edm.string_, "Executable Type")
      .collection("parameterBindings", Edm.string_, "Parameters (key=value)")
      .collection("inputArtifactBindings", Edm.string_, "Input Artifacts (key=artifactId)")
      .computed("executableType"))
    .writable(true, false, true)
    .titled("Configuration", "Configurations", "name", "executableId")
    .columns("name", "scenarioId", "executableId", "executableType", "resourceGroupId")
    .filters("resourceGroupId", "scenarioId", "executableId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Executions", "Execution"), "Execution ID")
      .property("configurationId", Edm.string_, "Configuration", false)
      .property("scenarioId", Edm.string_, "Scenario")
      .property("executableId", Edm.string_, "Executable")
      .property("scheduleId", Edm.string_, "Schedule")
      .property("status", Edm.string_, "Status")
      .property("targetStatus", Edm.string_, "Target Status")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("submissionTime", Edm.dateTimeOffset, "Submitted At")
      .property("startTime", Edm.dateTimeOffset, "Started At")
      .property("completionTime", Edm.dateTimeOffset, "Completed At")
      .property("durationSeconds", Edm.int32, "Duration (s)")
      .collection("outputArtifacts", Edm.string_, "Output Artifacts (key=artifactId)")
      .collection("tags", Edm.string_, "Tags")
      .property("metricCount", Edm.int32, "Metrics")
      .computed("id", "scenarioId", "executableId", "scheduleId", "status", "statusMessage", "submissionTime",
        "startTime", "completionTime", "durationSeconds", "outputArtifacts", "metricCount")
      .immutableProps("configurationId"))
    .writable()
    .titled("Execution", "Executions", "id", "status")
    .columns("id", "status", "configurationId", "scenarioId", "submissionTime", "durationSeconds", "resourceGroupId")
    .filters("resourceGroupId", "status", "scenarioId", "configurationId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Deployments", "Deployment"), "Deployment ID")
      .property("configurationId", Edm.string_, "Configuration", false)
      .property("latestRunningConfigurationId", Edm.string_, "Running Configuration")
      .property("scenarioId", Edm.string_, "Scenario")
      .property("executableId", Edm.string_, "Executable")
      .property("status", Edm.string_, "Status")
      .property("targetStatus", Edm.string_, "Target Status")
      .property("lastOperation", Edm.string_, "Last Operation")
      .property("statusMessage", Edm.string_, "Status Message")
      .property("deploymentUrl", Edm.string_, "Deployment URL")
      .property("ttlSeconds", Edm.int32, "Time to Live (s)")
      .property("submissionTime", Edm.dateTimeOffset, "Submitted At")
      .property("startTime", Edm.dateTimeOffset, "Started At")
      .property("completionTime", Edm.dateTimeOffset, "Stopped At")
      .property("expiresAt", Edm.dateTimeOffset, "Expires At")
      .computed("id", "latestRunningConfigurationId", "scenarioId", "executableId", "status", "lastOperation",
        "statusMessage", "deploymentUrl", "submissionTime", "startTime", "completionTime", "expiresAt")
      .immutableProps("ttlSeconds"))
    .writable()
    .titled("Deployment", "Deployments", "id", "status")
    .columns("id", "status", "configurationId", "deploymentUrl", "startTime", "resourceGroupId")
    .filters("resourceGroupId", "status", "scenarioId", "configurationId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Artifacts", "Artifact"), "Artifact ID")
      .property("name", Edm.string_, "Name", false)
      .property("kind", Edm.string_, "Kind")
      .property("url", Edm.string_, "URL", false)
      .property("description", Edm.string_, "Description")
      .property("scenarioId", Edm.string_, "Scenario", false)
      .property("executionId", Edm.string_, "Execution")
      .collection("labels", Edm.string_, "Labels")
      .immutableProps("name", "kind", "url", "scenarioId", "executionId"))
    .writable()
    .titled("Artifact", "Artifacts", "name", "url")
    .columns("name", "kind", "scenarioId", "executionId", "url", "resourceGroupId")
    .filters("resourceGroupId", "kind", "scenarioId", "executionId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("ExecutionSchedules", "ExecutionSchedule"), "Schedule ID")
      .property("name", Edm.string_, "Name")
      .property("configurationId", Edm.string_, "Configuration", false)
      .property("cron", Edm.string_, "Cron (UTC)", false)
      .property("status", Edm.string_, "Status")
      .property("startTime", Edm.dateTimeOffset, "Valid From")
      .property("endTime", Edm.dateTimeOffset, "Valid To")
      .property("lastRunAt", Edm.dateTimeOffset, "Last Run")
      .property("nextRunAt", Edm.dateTimeOffset, "Next Run")
      .property("lastExecutionId", Edm.string_, "Last Execution")
      .computed("lastRunAt", "nextRunAt", "lastExecutionId")
      .immutableProps("configurationId"))
    .writable()
    .titled("Execution Schedule", "Execution Schedules", "name", "cron")
    .columns("name", "cron", "status", "configurationId", "nextRunAt", "lastRunAt", "resourceGroupId")
    .filters("resourceGroupId", "status", "configurationId")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("Metrics", "Metric"), "Metric ID")
      .property("executionId", Edm.string_, "Execution", false)
      .property("name", Edm.string_, "Metric", false)
      .property("value", Edm.double_, "Value", false)
      .property("step", Edm.int32, "Step")
      .property("timestamp", Edm.dateTimeOffset, "Timestamp")
      .collection("labels", Edm.string_, "Labels")
      .computed("id"))
    .writable(true, false, true)
    .titled("Metric", "Metrics", "name", "executionId")
    .columns("executionId", "name", "step", "value", "timestamp", "resourceGroupId")
    .filters("resourceGroupId", "executionId", "name")
    .scopes(readScope, manageScope);

  audited(m.entitySet("DockerRegistrySecrets", "DockerRegistrySecret")
      .property("id", Edm.string_, "Secret Name", false)
      .property("server", Edm.string_, "Registry Server", false)
      .property("username", Edm.string_, "User", false)
      .property("password", Edm.string_, "Password (write only)")
      .property("hasCredentials", Edm.boolean, "Credentials Set")
      .property("credentialFingerprint", Edm.string_, "Fingerprint")
      .computed("hasCredentials", "credentialFingerprint"))
    .writable()
    .titled("Docker Registry Secret", "Docker Registry Secrets", "id", "server")
    .columns("id", "server", "username", "hasCredentials", "updatedAt")
    .scopes(readScope, manageScope);

  audited(grouped(m.entitySet("ObjectStoreSecrets", "ObjectStoreSecret"), "Secret Name")
      .property("type", Edm.string_, "Type")
      .property("bucket", Edm.string_, "Bucket", false)
      .property("endpoint", Edm.string_, "Endpoint")
      .property("region", Edm.string_, "Region")
      .property("pathPrefix", Edm.string_, "Path Prefix")
      .property("accessKeyId", Edm.string_, "Access Key ID (write only)")
      .property("secretAccessKey", Edm.string_, "Secret Access Key (write only)")
      .property("hasCredentials", Edm.boolean, "Credentials Set")
      .property("credentialFingerprint", Edm.string_, "Fingerprint")
      .computed("hasCredentials", "credentialFingerprint")
      .immutableProps("type"))
    .writable()
    .titled("Object Store Secret", "Object Store Secrets", "id", "bucket")
    .columns("id", "type", "bucket", "region", "hasCredentials", "resourceGroupId")
    .filters("resourceGroupId", "type")
    .scopes(readScope, manageScope);

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("resourceGroups", Edm.int32, "Resource Groups")
    .property("scenarios", Edm.int32, "Scenarios")
    .property("executables", Edm.int32, "Executables")
    .property("configurations", Edm.int32, "Configurations")
    .property("executions", Edm.int32, "Executions")
    .property("pendingExecutions", Edm.int32, "Pending Executions")
    .property("runningExecutions", Edm.int32, "Running Executions")
    .property("completedExecutions", Edm.int32, "Completed Executions")
    .property("failedExecutions", Edm.int32, "Stopped / Dead Executions")
    .property("deployments", Edm.int32, "Deployments")
    .property("runningDeployments", Edm.int32, "Running Deployments")
    .property("stoppedDeployments", Edm.int32, "Stopped Deployments")
    .property("artifacts", Edm.int32, "Artifacts")
    .property("models", Edm.int32, "Models")
    .property("datasets", Edm.int32, "Datasets")
    .property("schedules", Edm.int32, "Schedules")
    .property("activeSchedules", Edm.int32, "Active Schedules")
    .property("metrics", Edm.int32, "Metric Values")
    .property("secrets", Edm.int32, "Secrets")
    .property("computedAt", Edm.dateTimeOffset, "Computed At")
    .titled("Statistics", "Statistics")
    .scopes(readScope, "");

  m.complexType("RunResult")
    .property("key", Edm.string_, "Key")
    .property("id", Edm.string_, "ID")
    .property("status", Edm.string_, "Status")
    .property("targetStatus", Edm.string_, "Target Status")
    .property("statusMessage", Edm.string_, "Status Message");

  m.complexType("ReconcileResult")
    .property("resourceGroupsProvisioned", Edm.int32, "Resource Groups Provisioned")
    .property("executionsStarted", Edm.int32, "Executions Started")
    .property("executionsCompleted", Edm.int32, "Executions Completed")
    .property("executionsStopped", Edm.int32, "Executions Stopped")
    .property("deploymentsStarted", Edm.int32, "Deployments Started")
    .property("deploymentsStopped", Edm.int32, "Deployments Stopped")
    .property("deploymentsExpired", Edm.int32, "Deployments Expired")
    .property("schedulesFired", Edm.int32, "Schedules Fired")
    .property("artifactsCreated", Edm.int32, "Artifacts Created");

  m.complexType("SeedResult")
    .property("resourceGroups", Edm.int32, "Resource Groups")
    .property("scenarios", Edm.int32, "Scenarios")
    .property("executables", Edm.int32, "Executables")
    .property("configurations", Edm.int32, "Configurations")
    .property("artifacts", Edm.int32, "Artifacts")
    .property("executions", Edm.int32, "Executions")
    .property("deployments", Edm.int32, "Deployments")
    .property("schedules", Edm.int32, "Schedules")
    .property("metrics", Edm.int32, "Metric Values")
    .property("secrets", Edm.int32, "Secrets");

  m.complexType("CountResult").property("count", Edm.int32, "Count");

  m.action("StopExecution", "RunResult").parameter("key", Edm.string_, false)
    .labelled("Stop Execution").requires(manageScope);
  m.action("StopDeployment", "RunResult").parameter("key", Edm.string_, false)
    .labelled("Stop Deployment").requires(manageScope);
  m.action("ResumeDeployment", "RunResult").parameter("key", Edm.string_, false)
    .labelled("Restart Deployment").requires(manageScope);
  m.action("TriggerSchedule", "RunResult").parameter("key", Edm.string_, false)
    .labelled("Run Schedule Now").requires(manageScope);
  m.action("ClearMetrics", "CountResult").parameter("key", Edm.string_, false)
    .labelled("Clear Metrics of an Execution (execution key)").requires(manageScope);
  m.action("Reconcile", "ReconcileResult").labelled("Advance Lifecycles Now").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);

  m.validate();
  return m;
}

///
unittest {
  auto m = aiCoreModel();
  assert(m.has("Executions") && m.find("Statistics").singleton);
  assert(m.find("Executions").key == "key" && m.find("ResourceGroups").key == "id");
  assert(m.find("Configurations").insertable && !m.find("Configurations").updatable);
  assert(m.find("Executions").propertyOf("status").computed);
  assert(m.findAction("StopExecution").returnEdmType == "uim.aicore.RunResult");
}
