/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mappers.
module uim.platform.ai_core.persistence.mappers.entities;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

// ── ResourceGroup ───────────────────────────────────────────────────────────
Json resourceGroupToRecord(const ResourceGroup e) {
  auto d = auditRecord(e);
  d["status"] = cast(string) e.status;
  d["statusMessage"] = e.statusMessage;
  d["labels"] = labelsRecord(e.labels);
  return d;
}

ResourceGroup recordToResourceGroup(Json d) {
  ResourceGroup e;
  readAudit!(ResourceGroup, ResourceGroupId)(e, d);
  e.status = domainEnumOr!ResourceGroupStatus(textField(d, "status"), ResourceGroupStatus.provisioned);
  e.statusMessage = textField(d, "statusMessage");
  e.labels = labelsField(d, "labels");
  return e;
}

// ── Scenario ────────────────────────────────────────────────────────────────
Json scenarioToRecord(const Scenario e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["labels"] = labelsRecord(e.labels);
  return d;
}

Scenario recordToScenario(Json d) {
  Scenario e;
  readAudit!(Scenario, ScenarioId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.labels = labelsField(d, "labels");
  return e;
}

// ── Executable ──────────────────────────────────────────────────────────────
Json executableToRecord(const Executable e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["scenarioId"] = e.scenarioId.value;
  d["name"] = e.name;
  d["description"] = e.description;
  d["type"] = cast(string) e.type;
  d["versionId"] = e.versionId;
  d["parameters"] = parametersRecord(e.parameters);
  d["inputArtifacts"] = slotsRecord(e.inputArtifacts);
  d["outputArtifacts"] = slotsRecord(e.outputArtifacts);
  d["labels"] = labelsRecord(e.labels);
  return d;
}

Executable recordToExecutable(Json d) {
  Executable e;
  readAudit!(Executable, ExecutableId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.scenarioId = ScenarioId(textField(d, "scenarioId"));
  e.name = textField(d, "name");
  e.description = textField(d, "description");
  e.type = domainEnumOr!ExecutableType(textField(d, "type"), ExecutableType.workflow);
  e.versionId = textField(d, "versionId");
  e.parameters = parametersField(d, "parameters");
  e.inputArtifacts = slotsField(d, "inputArtifacts");
  e.outputArtifacts = slotsField(d, "outputArtifacts");
  e.labels = labelsField(d, "labels");
  return e;
}

// ── Configuration ───────────────────────────────────────────────────────────
Json configurationToRecord(const Configuration e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["scenarioId"] = e.scenarioId.value;
  d["executableId"] = e.executableId.value;
  d["name"] = e.name;
  d["parameterBindings"] = labelsRecord(e.parameterBindings);
  d["inputArtifactBindings"] = refsRecord(e.inputArtifactBindings);
  return d;
}

Configuration recordToConfiguration(Json d) {
  Configuration e;
  readAudit!(Configuration, ConfigurationId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.scenarioId = ScenarioId(textField(d, "scenarioId"));
  e.executableId = ExecutableId(textField(d, "executableId"));
  e.name = textField(d, "name");
  e.parameterBindings = labelsField(d, "parameterBindings");
  e.inputArtifactBindings = refsField(d, "inputArtifactBindings");
  return e;
}

// ── Execution ───────────────────────────────────────────────────────────────
Json executionToRecord(const Execution e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["configurationId"] = e.configurationId.value;
  d["scenarioId"] = e.scenarioId.value;
  d["executableId"] = e.executableId.value;
  d["scheduleId"] = e.scheduleId.value;
  d["status"] = cast(string) e.status;
  d["targetStatus"] = cast(string) e.targetStatus;
  d["statusMessage"] = e.statusMessage;
  d["submissionTime"] = e.submissionTime;
  d["startTime"] = e.startTime;
  d["completionTime"] = e.completionTime;
  d["outputArtifacts"] = refsRecord(e.outputArtifacts);
  d["tags"] = labelsRecord(e.tags);
  return d;
}

Execution recordToExecution(Json d) {
  Execution e;
  readAudit!(Execution, ExecutionId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.configurationId = ConfigurationId(textField(d, "configurationId"));
  e.scenarioId = ScenarioId(textField(d, "scenarioId"));
  e.executableId = ExecutableId(textField(d, "executableId"));
  e.scheduleId = ScheduleId(textField(d, "scheduleId"));
  e.status = domainEnumOr!ExecutionStatus(textField(d, "status"), ExecutionStatus.unknown);
  e.targetStatus = domainEnumOr!TargetStatus(textField(d, "targetStatus"), TargetStatus.completed);
  e.statusMessage = textField(d, "statusMessage");
  e.submissionTime = longField(d, "submissionTime");
  e.startTime = longField(d, "startTime");
  e.completionTime = longField(d, "completionTime");
  e.outputArtifacts = refsField(d, "outputArtifacts");
  e.tags = labelsField(d, "tags");
  return e;
}

// ── Deployment ──────────────────────────────────────────────────────────────
Json deploymentToRecord(const Deployment e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["configurationId"] = e.configurationId.value;
  d["latestRunningConfigurationId"] = e.latestRunningConfigurationId.value;
  d["scenarioId"] = e.scenarioId.value;
  d["executableId"] = e.executableId.value;
  d["status"] = cast(string) e.status;
  d["targetStatus"] = cast(string) e.targetStatus;
  d["lastOperation"] = cast(string) e.lastOperation;
  d["statusMessage"] = e.statusMessage;
  d["deploymentUrl"] = e.deploymentUrl;
  d["ttlSeconds"] = e.ttlSeconds;
  d["submissionTime"] = e.submissionTime;
  d["startTime"] = e.startTime;
  d["completionTime"] = e.completionTime;
  return d;
}

Deployment recordToDeployment(Json d) {
  Deployment e;
  readAudit!(Deployment, DeploymentId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.configurationId = ConfigurationId(textField(d, "configurationId"));
  e.latestRunningConfigurationId = ConfigurationId(textField(d, "latestRunningConfigurationId"));
  e.scenarioId = ScenarioId(textField(d, "scenarioId"));
  e.executableId = ExecutableId(textField(d, "executableId"));
  e.status = domainEnumOr!DeploymentStatus(textField(d, "status"), DeploymentStatus.unknown);
  e.targetStatus = domainEnumOr!TargetStatus(textField(d, "targetStatus"), TargetStatus.running);
  e.lastOperation = domainEnumOr!DeploymentOperation(textField(d, "lastOperation"), DeploymentOperation.create);
  e.statusMessage = textField(d, "statusMessage");
  e.deploymentUrl = textField(d, "deploymentUrl");
  e.ttlSeconds = longField(d, "ttlSeconds");
  e.submissionTime = longField(d, "submissionTime");
  e.startTime = longField(d, "startTime");
  e.completionTime = longField(d, "completionTime");
  return e;
}

// ── Artifact ────────────────────────────────────────────────────────────────
Json artifactToRecord(const Artifact e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["scenarioId"] = e.scenarioId.value;
  d["executionId"] = e.executionId.value;
  d["name"] = e.name;
  d["kind"] = cast(string) e.kind;
  d["url"] = e.url;
  d["description"] = e.description;
  d["labels"] = labelsRecord(e.labels);
  return d;
}

Artifact recordToArtifact(Json d) {
  Artifact e;
  readAudit!(Artifact, ArtifactId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.scenarioId = ScenarioId(textField(d, "scenarioId"));
  e.executionId = ExecutionId(textField(d, "executionId"));
  e.name = textField(d, "name");
  e.kind = domainEnumOr!ArtifactKind(textField(d, "kind"), ArtifactKind.other);
  e.url = textField(d, "url");
  e.description = textField(d, "description");
  e.labels = labelsField(d, "labels");
  return e;
}

// ── ExecutionSchedule ───────────────────────────────────────────────────────
Json scheduleToRecord(const ExecutionSchedule e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["configurationId"] = e.configurationId.value;
  d["name"] = e.name;
  d["cron"] = e.cron;
  d["status"] = cast(string) e.status;
  d["startTime"] = e.startTime;
  d["endTime"] = e.endTime;
  d["lastRunAt"] = e.lastRunAt;
  d["nextRunAt"] = e.nextRunAt;
  d["lastExecutionId"] = e.lastExecutionId.value;
  return d;
}

ExecutionSchedule recordToSchedule(Json d) {
  ExecutionSchedule e;
  readAudit!(ExecutionSchedule, ScheduleId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.configurationId = ConfigurationId(textField(d, "configurationId"));
  e.name = textField(d, "name");
  e.cron = textField(d, "cron");
  e.status = domainEnumOr!ScheduleStatus(textField(d, "status"), ScheduleStatus.inactive);
  e.startTime = longField(d, "startTime");
  e.endTime = longField(d, "endTime");
  e.lastRunAt = longField(d, "lastRunAt");
  e.nextRunAt = longField(d, "nextRunAt");
  e.lastExecutionId = ExecutionId(textField(d, "lastExecutionId"));
  return e;
}

// ── Metric ──────────────────────────────────────────────────────────────────
Json metricToRecord(const Metric e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["executionId"] = e.executionId.value;
  d["name"] = e.name;
  d["value"] = e.value;
  d["step"] = e.step;
  d["timestamp"] = e.timestamp;
  d["labels"] = labelsRecord(e.labels);
  return d;
}

Metric recordToMetric(Json d) {
  Metric e;
  readAudit!(Metric, MetricId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.executionId = ExecutionId(textField(d, "executionId"));
  e.name = textField(d, "name");
  e.value = doubleField(d, "value");
  e.step = longField(d, "step");
  e.timestamp = longField(d, "timestamp");
  e.labels = labelsField(d, "labels");
  return e;
}

// ── Secrets ─────────────────────────────────────────────────────────────────
Json dockerSecretToRecord(const DockerRegistrySecret e) {
  auto d = auditRecord(e);
  d["server"] = e.server;
  d["username"] = e.username;
  d["credentialFingerprint"] = e.credentialFingerprint;
  return d;
}

DockerRegistrySecret recordToDockerSecret(Json d) {
  DockerRegistrySecret e;
  readAudit!(DockerRegistrySecret, DockerRegistrySecretId)(e, d);
  e.server = textField(d, "server");
  e.username = textField(d, "username");
  e.credentialFingerprint = textField(d, "credentialFingerprint");
  return e;
}

Json objectStoreSecretToRecord(const ObjectStoreSecret e) {
  auto d = auditRecord(e);
  d["resourceGroupId"] = e.resourceGroupId.value;
  d["type"] = cast(string) e.type;
  d["bucket"] = e.bucket;
  d["endpoint"] = e.endpoint;
  d["region"] = e.region;
  d["pathPrefix"] = e.pathPrefix;
  d["credentialFingerprint"] = e.credentialFingerprint;
  return d;
}

ObjectStoreSecret recordToObjectStoreSecret(Json d) {
  ObjectStoreSecret e;
  readAudit!(ObjectStoreSecret, ObjectStoreSecretId)(e, d);
  e.resourceGroupId = ResourceGroupId(textField(d, "resourceGroupId"));
  e.type = domainEnumOr!ObjectStoreType(textField(d, "type"), ObjectStoreType.s3);
  e.bucket = textField(d, "bucket");
  e.endpoint = textField(d, "endpoint");
  e.region = textField(d, "region");
  e.pathPrefix = textField(d, "pathPrefix");
  e.credentialFingerprint = textField(d, "credentialFingerprint");
  return e;
}

///
unittest {
  Executable e;
  e.id = ExecutableId("x");
  e.type = ExecutableType.serving;
  e.parameters = [ParameterDef("p", "string", "1", "d")];
  e.inputArtifacts = [ArtifactSlot("m", ArtifactKind.model, "")];
  e.labels = [Label("a", "b")];
  auto back = recordToExecutable(executableToRecord(e));
  assert(back.id == e.id && back.type == ExecutableType.serving && back.parameters == e.parameters);
  assert(back.inputArtifacts == e.inputArtifacts && back.labels == e.labels);

  Metric m;
  m.value = 0.25;
  m.step = 3;
  auto mb = recordToMetric(metricToRecord(m));
  assert(mb.value == 0.25 && mb.step == 3);
}
