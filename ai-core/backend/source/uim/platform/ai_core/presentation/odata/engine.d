/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the CLI and the GUI.
module uim.platform.ai_core.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates AiCoreException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

private size_t[string] countBy(T)(T[] items, scope string delegate(const T) @safe keyOf) {
  size_t[string] counts;
  foreach (i; items)
    counts[keyOf(i)]++;
  return counts;
}

ODataEngine aiCoreEngine(AiCorePorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(aiCoreModel());
  auto none = ResourceGroupId.init;

  // ── Resource groups ─────────────────────────────────────────────────────
  Json groupRow(TenantId t, const ResourceGroup g) {
    return resourceGroupRow(g, ports.scenarios.listScenarios(t, g.id).length,
      ports.executions.listExecutions(t, g.id).length, ports.deployments.listDeployments(t, g.id).length);
  }

  auto groups = new DelegateEntitySetProvider;
  groups.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto scenarios = countBy(ports.scenarios.listScenarios(t, none), (const Scenario s) => s.resourceGroupId.value);
    auto executions = countBy(ports.executions.listExecutions(t, none), (const Execution e) => e.resourceGroupId.value);
    auto deployments = countBy(ports.deployments.listDeployments(t, none), (const Deployment d) => d.resourceGroupId.value);
    Json[] rows;
    foreach (g; ports.resourceGroups.listResourceGroups(t))
      rows ~= resourceGroupRow(g, scenarios.get(g.id.value, 0), executions.get(g.id.value, 0), deployments.get(g.id.value, 0));
    return rows;
  };
  groups.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    return groupRow(t, ports.resourceGroups.getResourceGroup(t, ResourceGroupId(key)));
  };
  groups.onCreate = (const RequestContext ctx, Json p) {
    auto g = ports.resourceGroups.createResourceGroup(createResourceGroupRequest(ctx, p));
    return resourceGroupRow(g);
  };
  groups.onUpdate = (const RequestContext ctx, string key, Json p) {
    UpdateResourceGroupRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.id = key;
    if (has(p, "labels"))
      r.labels = labelsOf(p, "labels");
    return groupRow(r.tenantId, ports.resourceGroups.updateResourceGroup(r));
  };
  groups.onRemove = (const RequestContext ctx, string key) {
    ports.resourceGroups.deleteResourceGroup(tenantOf(ctx), ResourceGroupId(key));
  };

  // ── Scenarios ───────────────────────────────────────────────────────────
  Json scenarioWithCounts(TenantId t, const Scenario s) {
    return scenarioRow(s, ports.executables.listExecutables(t, s.resourceGroupId, s.id).length,
      ports.configurations.listConfigurations(t, s.resourceGroupId, ConfigurationFilter(s.id)).length,
      ports.artifacts.listArtifacts(t, s.resourceGroupId, ArtifactFilter(s.id)).length);
  }

  auto scenarios = new DelegateEntitySetProvider;
  scenarios.keyProperty = "key";
  scenarios.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto key = (string rg, string id) => resourceKey(rg, id);
    auto executables = countBy(ports.executables.listExecutables(t, none), (const Executable e) => key(e.resourceGroupId.value, e.scenarioId.value));
    auto configurations = countBy(ports.configurations.listConfigurations(t, none), (const Configuration c) => key(c.resourceGroupId.value, c.scenarioId.value));
    auto artifacts = countBy(ports.artifacts.listArtifacts(t, none), (const Artifact a) => key(a.resourceGroupId.value, a.scenarioId.value));
    Json[] rows;
    foreach (s; ports.scenarios.listScenarios(t, none)) {
      auto k = key(s.resourceGroupId.value, s.id.value);
      rows ~= scenarioRow(s, executables.get(k, 0), configurations.get(k, 0), artifacts.get(k, 0));
    }
    return rows;
  };
  scenarios.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Scenario");
    auto t = tenantOf(ctx);
    return scenarioWithCounts(t, ports.scenarios.getScenario(t, rg, ScenarioId(id)));
  };
  scenarios.onCreate = (const RequestContext ctx, Json p) => scenarioRow(ports.scenarios.createScenario(createScenarioRequest(ctx, p)));
  scenarios.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto s = ports.scenarios.updateScenario(updateScenarioRequest(ctx, key, p));
    return scenarioWithCounts(tenantOf(ctx), s);
  };
  scenarios.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Scenario");
    ports.scenarios.deleteScenario(tenantOf(ctx), rg, ScenarioId(id));
  };

  // ── Executables ─────────────────────────────────────────────────────────
  auto executables = new DelegateEntitySetProvider;
  executables.keyProperty = "key";
  executables.onList = (const RequestContext ctx) => ports.executables.listExecutables(tenantOf(ctx), none)
    .map!(e => executableRow(e)).array;
  executables.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Executable");
    return executableRow(ports.executables.getExecutable(tenantOf(ctx), rg, ExecutableId(id)));
  };
  executables.onCreate = (const RequestContext ctx, Json p) => executableRow(
    ports.executables.createExecutable(createExecutableRequest(ctx, p)));
  executables.onUpdate = (const RequestContext ctx, string key, Json p) => executableRow(
    ports.executables.updateExecutable(updateExecutableRequest(ctx, key, p)));
  executables.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Executable");
    ports.executables.deleteExecutable(tenantOf(ctx), rg, ExecutableId(id));
  };

  // ── Configurations ──────────────────────────────────────────────────────
  string typeOf(TenantId t, const Configuration c) {
    try
      return cast(string) ports.executables.getExecutable(t, c.resourceGroupId, c.executableId).type;
    catch (AiCoreException)
      return "";
  }

  auto configurations = new DelegateEntitySetProvider;
  configurations.keyProperty = "key";
  configurations.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    string[string] types;
    foreach (e; ports.executables.listExecutables(t, none))
      types[resourceKey(e.resourceGroupId.value, e.id.value)] = cast(string) e.type;
    Json[] rows;
    foreach (c; ports.configurations.listConfigurations(t, none))
      rows ~= configurationRow(c, types.get(resourceKey(c.resourceGroupId.value, c.executableId.value), ""));
    return rows;
  };
  configurations.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Configuration");
    auto t = tenantOf(ctx);
    auto c = ports.configurations.getConfiguration(t, rg, ConfigurationId(id));
    return configurationRow(c, typeOf(t, c));
  };
  configurations.onCreate = (const RequestContext ctx, Json p) {
    auto c = ports.configurations.createConfiguration(createConfigurationRequest(ctx, p));
    return configurationRow(c, typeOf(tenantOf(ctx), c));
  };
  configurations.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Configuration");
    ports.configurations.deleteConfiguration(tenantOf(ctx), rg, ConfigurationId(id));
  };

  // ── Executions ──────────────────────────────────────────────────────────
  Json executionWithMetrics(TenantId t, const Execution e) {
    return executionRow(e, clock.now, ports.metrics.listMetrics(t, e.resourceGroupId, e.id).length);
  }

  auto executions = new DelegateEntitySetProvider;
  executions.keyProperty = "key";
  executions.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto metrics = countBy(ports.metrics.listMetrics(t, none), (const Metric m) => resourceKey(m.resourceGroupId.value, m.executionId.value));
    auto now = clock.now;
    Json[] rows;
    foreach (e; ports.executions.listExecutions(t, none))
      rows ~= executionRow(e, now, metrics.get(resourceKey(e.resourceGroupId.value, e.id.value), 0));
    return rows;
  };
  executions.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Execution");
    auto t = tenantOf(ctx);
    return executionWithMetrics(t, ports.executions.getExecution(t, rg, ExecutionId(id)));
  };
  executions.onCreate = (const RequestContext ctx, Json p) {
    CreateExecutionRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
    r.configurationId = textOf(p, "configurationId");
    r.tags = labelsOf(p, "tags");
    return executionRow(ports.executions.createExecution(r), clock.now);
  };
  executions.onUpdate = (const RequestContext ctx, string key, Json p) {
    PatchExecutionRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    splitKey(key, r.resourceGroupId, r.id, "Execution");
    r.targetStatus = textOf(p, "targetStatus");
    if (r.targetStatus.length == 0)
      throw AiCoreException.invalid("Only targetStatus (STOPPED) can be changed");
    auto e = ports.executions.patchExecution(r);
    return executionWithMetrics(r.tenantId, e);
  };
  executions.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Execution");
    ports.executions.deleteExecution(tenantOf(ctx), rg, ExecutionId(id));
  };

  // ── Deployments ─────────────────────────────────────────────────────────
  auto deployments = new DelegateEntitySetProvider;
  deployments.keyProperty = "key";
  deployments.onList = (const RequestContext ctx) => ports.deployments.listDeployments(tenantOf(ctx), none)
    .map!(d => deploymentRow(d)).array;
  deployments.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Deployment");
    return deploymentRow(ports.deployments.getDeployment(tenantOf(ctx), rg, DeploymentId(id)));
  };
  deployments.onCreate = (const RequestContext ctx, Json p) {
    CreateDeploymentRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
    r.configurationId = textOf(p, "configurationId");
    r.ttlSeconds = longOf(p, "ttlSeconds");
    return deploymentRow(ports.deployments.createDeployment(r));
  };
  deployments.onUpdate = (const RequestContext ctx, string key, Json p) {
    PatchDeploymentRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    splitKey(key, r.resourceGroupId, r.id, "Deployment");
    r.targetStatus = textOf(p, "targetStatus");
    r.configurationId = textOf(p, "configurationId");
    return deploymentRow(ports.deployments.patchDeployment(r));
  };
  deployments.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Deployment");
    ports.deployments.deleteDeployment(tenantOf(ctx), rg, DeploymentId(id));
  };

  // ── Artifacts ───────────────────────────────────────────────────────────
  auto artifacts = new DelegateEntitySetProvider;
  artifacts.keyProperty = "key";
  artifacts.onList = (const RequestContext ctx) => ports.artifacts.listArtifacts(tenantOf(ctx), none)
    .map!(a => artifactRow(a)).array;
  artifacts.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Artifact");
    return artifactRow(ports.artifacts.getArtifact(tenantOf(ctx), rg, ArtifactId(id)));
  };
  artifacts.onCreate = (const RequestContext ctx, Json p) => artifactRow(ports.artifacts.createArtifact(createArtifactRequest(ctx, p)));
  artifacts.onUpdate = (const RequestContext ctx, string key, Json p) => artifactRow(
    ports.artifacts.updateArtifact(updateArtifactRequest(ctx, key, p)));
  artifacts.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Artifact");
    ports.artifacts.deleteArtifact(tenantOf(ctx), rg, ArtifactId(id));
  };

  // ── Execution schedules ─────────────────────────────────────────────────
  auto schedules = new DelegateEntitySetProvider;
  schedules.keyProperty = "key";
  schedules.onList = (const RequestContext ctx) => ports.schedules.listSchedules(tenantOf(ctx), none)
    .map!(s => scheduleRow(s)).array;
  schedules.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Execution schedule");
    return scheduleRow(ports.schedules.getSchedule(tenantOf(ctx), rg, ScheduleId(id)));
  };
  schedules.onCreate = (const RequestContext ctx, Json p) => scheduleRow(ports.schedules.createSchedule(createScheduleRequest(ctx, p)));
  schedules.onUpdate = (const RequestContext ctx, string key, Json p) => scheduleRow(
    ports.schedules.updateSchedule(updateScheduleRequest(ctx, key, p)));
  schedules.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Execution schedule");
    ports.schedules.deleteSchedule(tenantOf(ctx), rg, ScheduleId(id));
  };

  // ── Metrics ─────────────────────────────────────────────────────────────
  auto metrics = new DelegateEntitySetProvider;
  metrics.keyProperty = "key";
  metrics.onList = (const RequestContext ctx) => ports.metrics.listMetrics(tenantOf(ctx), none).map!(m => metricRow(m)).array;
  metrics.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Metric");
    return metricRow(ports.metrics.getMetric(tenantOf(ctx), rg, MetricId(id)));
  };
  metrics.onCreate = (const RequestContext ctx, Json p) {
    LogMetricsRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.resourceGroupId = ResourceGroupId(textOf(p, "resourceGroupId"));
    r.executionId = textOf(p, "executionId");
    r.metrics = [MetricInput(textOf(p, "name"), doubleOf(p, "value"), longOf(p, "step"), timeOf(p, "timestamp"), labelsOf(p, "labels"))];
    ports.metrics.logMetrics(r);
    auto id = Metric.idFor(r.executionId, r.metrics[0].name.strip, r.metrics[0].step);
    return metricRow(ports.metrics.getMetric(r.tenantId, r.resourceGroupId, MetricId(id)));
  };
  metrics.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Metric");
    ports.metrics.deleteMetric(tenantOf(ctx), rg, MetricId(id));
  };

  // ── Secrets ─────────────────────────────────────────────────────────────
  auto dockerSecrets = new DelegateEntitySetProvider;
  dockerSecrets.onList = (const RequestContext ctx) => ports.secrets.listDockerRegistrySecrets(tenantOf(ctx))
    .map!(s => dockerSecretRow(s)).array;
  dockerSecrets.onGet = (const RequestContext ctx, string key) => dockerSecretRow(
    ports.secrets.getDockerRegistrySecret(tenantOf(ctx), DockerRegistrySecretId(key)));
  dockerSecrets.onCreate = (const RequestContext ctx, Json p) => dockerSecretRow(
    ports.secrets.createDockerRegistrySecret(createDockerSecretRequest(ctx, p)));
  dockerSecrets.onUpdate = (const RequestContext ctx, string key, Json p) => dockerSecretRow(
    ports.secrets.updateDockerRegistrySecret(updateDockerSecretRequest(ctx, key, p)));
  dockerSecrets.onRemove = (const RequestContext ctx, string key) {
    ports.secrets.deleteDockerRegistrySecret(tenantOf(ctx), DockerRegistrySecretId(key));
  };

  auto storeSecrets = new DelegateEntitySetProvider;
  storeSecrets.keyProperty = "key";
  storeSecrets.onList = (const RequestContext ctx) => ports.secrets.listObjectStoreSecrets(tenantOf(ctx), none)
    .map!(s => objectStoreSecretRow(s)).array;
  storeSecrets.onGet = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Object store secret");
    return objectStoreSecretRow(ports.secrets.getObjectStoreSecret(tenantOf(ctx), rg, ObjectStoreSecretId(id)));
  };
  storeSecrets.onCreate = (const RequestContext ctx, Json p) => objectStoreSecretRow(
    ports.secrets.createObjectStoreSecret(createObjectStoreSecretRequest(ctx, p)));
  storeSecrets.onUpdate = (const RequestContext ctx, string key, Json p) => objectStoreSecretRow(
    ports.secrets.updateObjectStoreSecret(updateObjectStoreSecretRequest(ctx, key, p)));
  storeSecrets.onRemove = (const RequestContext ctx, string key) {
    ResourceGroupId rg;
    string id;
    splitKey(key, rg, id, "Object store secret");
    ports.secrets.deleteObjectStoreSecret(tenantOf(ctx), rg, ObjectStoreSecretId(id));
  };

  // ── Statistics (singleton) ──────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("ResourceGroups", new PortProvider(groups))
    .provide("Scenarios", new PortProvider(scenarios))
    .provide("Executables", new PortProvider(executables))
    .provide("Configurations", new PortProvider(configurations))
    .provide("Executions", new PortProvider(executions))
    .provide("Deployments", new PortProvider(deployments))
    .provide("Artifacts", new PortProvider(artifacts))
    .provide("ExecutionSchedules", new PortProvider(schedules))
    .provide("Metrics", new PortProvider(metrics))
    .provide("DockerRegistrySecrets", new PortProvider(dockerSecrets))
    .provide("ObjectStoreSecrets", new PortProvider(storeSecrets))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ─────────────────────────────────────────────────────────────
  engine.handle("StopExecution", (const RequestContext ctx, Json p) => translated!Json(() {
      PatchExecutionRequest r;
      r.tenantId = tenantOf(ctx);
      r.actor = actorOf(ctx);
      splitKey(textOf(p, "key"), r.resourceGroupId, r.id, "Execution");
      r.targetStatus = cast(string) TargetStatus.stopped;
      return runResultRow(ports.executions.patchExecution(r));
    }));
  engine.handle("StopDeployment", (const RequestContext ctx, Json p) => translated!Json(() {
      PatchDeploymentRequest r;
      r.tenantId = tenantOf(ctx);
      r.actor = actorOf(ctx);
      splitKey(textOf(p, "key"), r.resourceGroupId, r.id, "Deployment");
      r.targetStatus = cast(string) TargetStatus.stopped;
      return runResultRow(ports.deployments.patchDeployment(r));
    }));
  engine.handle("ResumeDeployment", (const RequestContext ctx, Json p) => translated!Json(() {
      PatchDeploymentRequest r;
      r.tenantId = tenantOf(ctx);
      r.actor = actorOf(ctx);
      splitKey(textOf(p, "key"), r.resourceGroupId, r.id, "Deployment");
      r.targetStatus = cast(string) TargetStatus.running;
      return runResultRow(ports.deployments.patchDeployment(r));
    }));
  engine.handle("TriggerSchedule", (const RequestContext ctx, Json p) => translated!Json(() {
      ResourceGroupId rg;
      string id;
      splitKey(textOf(p, "key"), rg, id, "Execution schedule");
      return runResultRow(ports.schedules.triggerSchedule(tenantOf(ctx), rg, ScheduleId(id), actorOf(ctx)));
    }));
  engine.handle("ClearMetrics", (const RequestContext ctx, Json p) => translated!Json(() {
      ResourceGroupId rg;
      string id;
      splitKey(textOf(p, "key"), rg, id, "Execution");
      return Json(["count": Json(ports.metrics.clearMetrics(tenantOf(ctx), rg, ExecutionId(id)))]);
    }));
  engine.handle("Reconcile", (const RequestContext ctx, Json p) => translated!Json(() => reconcileRow(
      ports.reconciler.reconcile(tenantOf(ctx)))));
  engine.handle("SeedDemoData", (const RequestContext ctx, Json p) => translated!Json(() => seedRow(
      seedDemoData(ports, tenantOf(ctx), actorOf(ctx)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
