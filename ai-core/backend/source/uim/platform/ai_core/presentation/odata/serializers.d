/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Secret material
/// is never serialized; write-only properties read as null.
module uim.platform.ai_core.presentation.odata.serializers;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// ISO 8601 (seconds precision, UTC) or null for 0.
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

/// Empty text → null (optional references).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

private Json groupedRow(E)(const E e) {
  auto j = auditRow(e);
  j["key"] = resourceKey(e.resourceGroupId.value, e.id.value);
  j["id"] = e.id.value;
  j["resourceGroupId"] = e.resourceGroupId.value;
  return j;
}

Json resourceGroupRow(const ResourceGroup e, size_t scenarios = 0, size_t executions = 0, size_t deployments = 0) {
  auto j = auditRow(e);
  j["id"] = e.id.value;
  j["status"] = cast(string) e.status;
  j["statusMessage"] = e.statusMessage;
  j["labels"] = texts(labelTexts(e.labels));
  j["scenarioCount"] = scenarios;
  j["executionCount"] = executions;
  j["deploymentCount"] = deployments;
  return j;
}

Json scenarioRow(const Scenario e, size_t executables = 0, size_t configurations = 0, size_t artifacts = 0) {
  auto j = groupedRow(e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["labels"] = texts(labelTexts(e.labels));
  j["executableCount"] = executables;
  j["configurationCount"] = configurations;
  j["artifactCount"] = artifacts;
  return j;
}

Json executableRow(const Executable e) {
  auto j = groupedRow(e);
  j["scenarioId"] = e.scenarioId.value;
  j["name"] = e.name;
  j["description"] = e.description;
  j["type"] = cast(string) e.type;
  j["versionId"] = e.versionId;
  j["deployable"] = e.deployable;
  j["parameters"] = texts(e.parameters.map!(p => parameterText(p)).array);
  j["inputArtifacts"] = texts(e.inputArtifacts.map!(s => slotText(s)).array);
  j["outputArtifacts"] = texts(e.outputArtifacts.map!(s => slotText(s)).array);
  j["labels"] = texts(labelTexts(e.labels));
  return j;
}

Json configurationRow(const Configuration e, string executableType = "") {
  auto j = groupedRow(e);
  j["name"] = e.name;
  j["scenarioId"] = e.scenarioId.value;
  j["executableId"] = e.executableId.value;
  j["executableType"] = textOrNull(executableType);
  j["parameterBindings"] = texts(labelTexts(e.parameterBindings));
  j["inputArtifactBindings"] = texts(e.inputArtifactBindings.map!(r => refText(r)).array);
  return j;
}

Json executionRow(const Execution e, long now, size_t metrics = 0) {
  auto j = groupedRow(e);
  j["configurationId"] = e.configurationId.value;
  j["scenarioId"] = e.scenarioId.value;
  j["executableId"] = e.executableId.value;
  j["scheduleId"] = textOrNull(e.scheduleId.value);
  j["status"] = cast(string) e.status;
  j["targetStatus"] = cast(string) e.targetStatus;
  j["statusMessage"] = e.statusMessage;
  j["submissionTime"] = isoTime(e.submissionTime);
  j["startTime"] = isoTime(e.startTime);
  j["completionTime"] = isoTime(e.completionTime);
  j["durationSeconds"] = e.durationSeconds(now);
  j["outputArtifacts"] = texts(e.outputArtifacts.map!(r => refText(r)).array);
  j["tags"] = texts(labelTexts(e.tags));
  j["metricCount"] = metrics;
  return j;
}

Json deploymentRow(const Deployment e) {
  auto j = groupedRow(e);
  j["configurationId"] = e.configurationId.value;
  j["latestRunningConfigurationId"] = textOrNull(e.latestRunningConfigurationId.value);
  j["scenarioId"] = e.scenarioId.value;
  j["executableId"] = e.executableId.value;
  j["status"] = cast(string) e.status;
  j["targetStatus"] = cast(string) e.targetStatus;
  j["lastOperation"] = cast(string) e.lastOperation;
  j["statusMessage"] = e.statusMessage;
  j["deploymentUrl"] = textOrNull(e.deploymentUrl);
  j["ttlSeconds"] = e.ttlSeconds;
  j["submissionTime"] = isoTime(e.submissionTime);
  j["startTime"] = isoTime(e.startTime);
  j["completionTime"] = isoTime(e.completionTime);
  j["expiresAt"] = isoTime(e.expiresAt);
  return j;
}

Json artifactRow(const Artifact e) {
  auto j = groupedRow(e);
  j["name"] = e.name;
  j["kind"] = cast(string) e.kind;
  j["url"] = e.url;
  j["description"] = e.description;
  j["scenarioId"] = e.scenarioId.value;
  j["executionId"] = textOrNull(e.executionId.value);
  j["labels"] = texts(labelTexts(e.labels));
  return j;
}

Json scheduleRow(const ExecutionSchedule e) {
  auto j = groupedRow(e);
  j["name"] = e.name;
  j["configurationId"] = e.configurationId.value;
  j["cron"] = e.cron;
  j["status"] = cast(string) e.status;
  j["startTime"] = isoTime(e.startTime);
  j["endTime"] = isoTime(e.endTime);
  j["lastRunAt"] = isoTime(e.lastRunAt);
  j["nextRunAt"] = isoTime(e.nextRunAt);
  j["lastExecutionId"] = textOrNull(e.lastExecutionId.value);
  return j;
}

Json metricRow(const Metric e) {
  auto j = groupedRow(e);
  j["executionId"] = e.executionId.value;
  j["name"] = e.name;
  j["value"] = e.value;
  j["step"] = e.step;
  j["timestamp"] = isoTime(e.timestamp);
  j["labels"] = texts(labelTexts(e.labels));
  return j;
}

Json dockerSecretRow(const DockerRegistrySecret e) {
  auto j = auditRow(e);
  j["id"] = e.id.value;
  j["server"] = e.server;
  j["username"] = e.username;
  j["password"] = Json(null);
  j["hasCredentials"] = e.hasCredentials;
  j["credentialFingerprint"] = textOrNull(e.credentialFingerprint);
  return j;
}

Json objectStoreSecretRow(const ObjectStoreSecret e) {
  auto j = groupedRow(e);
  j["type"] = cast(string) e.type;
  j["bucket"] = e.bucket;
  j["endpoint"] = e.endpoint;
  j["region"] = e.region;
  j["pathPrefix"] = e.pathPrefix;
  j["accessKeyId"] = Json(null);
  j["secretAccessKey"] = Json(null);
  j["hasCredentials"] = e.hasCredentials;
  j["credentialFingerprint"] = textOrNull(e.credentialFingerprint);
  return j;
}

Json statisticsRow(const AiCoreStatistics s) {
  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId;
  j["resourceGroups"] = s.resourceGroups;
  j["scenarios"] = s.scenarios;
  j["executables"] = s.executables;
  j["configurations"] = s.configurations;
  j["executions"] = s.executions;
  j["pendingExecutions"] = s.pendingExecutions;
  j["runningExecutions"] = s.runningExecutions;
  j["completedExecutions"] = s.completedExecutions;
  j["failedExecutions"] = s.failedExecutions;
  j["deployments"] = s.deployments;
  j["runningDeployments"] = s.runningDeployments;
  j["stoppedDeployments"] = s.stoppedDeployments;
  j["artifacts"] = s.artifacts;
  j["models"] = s.models;
  j["datasets"] = s.datasets;
  j["schedules"] = s.schedules;
  j["activeSchedules"] = s.activeSchedules;
  j["metrics"] = s.metrics;
  j["secrets"] = s.secrets;
  j["computedAt"] = isoTime(s.computedAt);
  return j;
}

Json runResultRow(string key, string id, string status, string targetStatus, string message) {
  auto j = Json.emptyObject;
  j["key"] = key;
  j["id"] = id;
  j["status"] = status;
  j["targetStatus"] = targetStatus;
  j["statusMessage"] = message;
  return j;
}

Json runResultRow(const Execution e) {
  return runResultRow(resourceKey(e.resourceGroupId.value, e.id.value), e.id.value, cast(string) e.status,
    cast(string) e.targetStatus, e.statusMessage);
}

Json runResultRow(const Deployment d) {
  return runResultRow(resourceKey(d.resourceGroupId.value, d.id.value), d.id.value, cast(string) d.status,
    cast(string) d.targetStatus, d.statusMessage);
}

Json reconcileRow(const ReconcileResult r) {
  auto j = Json.emptyObject;
  j["resourceGroupsProvisioned"] = r.resourceGroupsProvisioned;
  j["executionsStarted"] = r.executionsStarted;
  j["executionsCompleted"] = r.executionsCompleted;
  j["executionsStopped"] = r.executionsStopped;
  j["deploymentsStarted"] = r.deploymentsStarted;
  j["deploymentsStopped"] = r.deploymentsStopped;
  j["deploymentsExpired"] = r.deploymentsExpired;
  j["schedulesFired"] = r.schedulesFired;
  j["artifactsCreated"] = r.artifactsCreated;
  return j;
}

Json seedRow(const DemoDataResult r) {
  auto j = Json.emptyObject;
  j["resourceGroups"] = r.resourceGroups;
  j["scenarios"] = r.scenarios;
  j["executables"] = r.executables;
  j["configurations"] = r.configurations;
  j["artifacts"] = r.artifacts;
  j["executions"] = r.executions;
  j["deployments"] = r.deployments;
  j["schedules"] = r.schedules;
  j["metrics"] = r.metrics;
  j["secrets"] = r.secrets;
  return j;
}
