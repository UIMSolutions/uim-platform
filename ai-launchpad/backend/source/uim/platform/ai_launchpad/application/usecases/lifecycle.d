/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The ML life cycle: scenarios, configurations, executions and deployments.
///
///   • A scenario belongs to a connection; it can only be deleted without
///     configurations, models and datasets.
///   • A configuration uses an executable the scenario offers; its input
///     artifacts must be datasets or models of the scenario. It is immutable
///     once an execution or deployment uses it.
///   • Executions and deployments need an active connection and a ready
///     resource group of that connection. They start as "pending"; the
///     reconciliation with the runtime moves them on. Only finished
///     executions and stopped / dead deployments can be deleted.
module uim.platform.ai_launchpad.application.usecases.lifecycle;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ManageScenariosUseCase : ResourceInteractor!(Scenario, ScenarioId, ScenarioInput), IManageScenarios {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Scenario, ScenarioId) store() {
    return repos.scenarios;
  }

  protected override string what() {
    return "Scenario";
  }

  protected override string eventPrefix() {
    return "scenario";
  }

  protected override string[] immutableAttributes() {
    return ["connectionId"];
  }

  protected override ScenarioInput toInput(const Scenario e) {
    return ScenarioInput(e.connectionId.value, e.name, e.description, e.executables.dup, e.labels.dup);
  }

  protected override void fromInput(TenantId t, ref Scenario e, ScenarioInput i, bool creating) {
    if (creating)
      e.connectionId = connectionOf(t, i.connectionId).id;
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.description = i.description.strip;
    e.executables = i.executables.map!(x => x.strip).filter!(x => x.length > 0).array;
    e.labels = i.labels.map!(x => x.strip).filter!(x => x.length > 0).array;
  }

  protected override void beforeSave(TenantId t, ref Scenario e, bool creating, const string[] changed) {
    if (creating || !changed.canFind("executables"))
      return;
    foreach (c; repos.configurations.findByReference(t, "scenarioId", e.id.value))
      if (!e.offers(c.executableId))
        throw AilpException.ruleViolation("Executable '" ~ c.executableId ~ "' is still used by configuration '"
            ~ c.id.value ~ "'");
  }

  protected override void beforeRemove(TenantId t, const Scenario e, UserId actor) {
    auto s = e.id.value;
    requireUnused("Scenario '" ~ s ~ "'", repos.configurations.countByReference(t, "scenarioId", s), "configurations");
    requireUnused("Scenario '" ~ s ~ "'", repos.models.countByReference(t, "scenarioId", s), "models");
    requireUnused("Scenario '" ~ s ~ "'", repos.datasets.countByReference(t, "scenarioId", s), "datasets");
  }
}

class ManageConfigurationsUseCase : ResourceInteractor!(Configuration, ConfigurationId, ConfigurationInput), IManageConfigurations {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Configuration, ConfigurationId) store() {
    return repos.configurations;
  }

  protected override string what() {
    return "Configuration";
  }

  protected override string eventPrefix() {
    return "configuration";
  }

  protected override string[] immutableAttributes() {
    return ["scenarioId"];
  }

  protected override ConfigurationInput toInput(const Configuration e) {
    return ConfigurationInput(e.scenarioId.value, e.name, e.executableId, e.parameters.dup, e.inputArtifacts.dup);
  }

  protected override void fromInput(TenantId t, ref Configuration e, ConfigurationInput i, bool creating) {
    if (creating) {
      auto s = scenarioOf(t, i.scenarioId);
      e.scenarioId = s.id;
      e.connectionId = s.connectionId;
    }
    e.name = i.name.strip.length ? i.name.strip : e.id.value;
    e.executableId = i.executableId.strip;
    e.parameters = i.parameters.map!(x => x.strip).filter!(x => x.length > 0).array;
    e.inputArtifacts = i.inputArtifacts.map!(x => x.strip).filter!(x => x.length > 0).array;
  }

  protected override void beforeSave(TenantId t, ref Configuration e, bool creating, const string[] changed) {
    if (!creating && changed.length)
      requireUnused("Configuration '" ~ e.id.value ~ "' (create a new configuration instead)", usages(t, e.id.value),
        "executions or deployments");
    auto s = scenarioOf(t, e.scenarioId.value);
    if (!s.offers(e.executableId))
      throw AilpException.ruleViolation("Scenario '" ~ s.id.value ~ "' offers no executable '" ~ e.executableId
          ~ "' (available: " ~ s.executables.join(", ") ~ ")");
    foreach (artifact; e.artifactIds) {
      auto ds = repos.datasets.findById(t, DatasetId(artifact));
      auto m = repos.models.findById(t, ModelId(artifact));
      if (ds.isNull && m.isNull)
        throw AilpException.ruleViolation("Input artifact '" ~ artifact ~ "' is neither a dataset nor a model");
      auto owner = ds.isNull ? m.scenarioId : ds.scenarioId;
      if (owner != e.scenarioId)
        throw AilpException.ruleViolation("Input artifact '" ~ artifact ~ "' belongs to scenario '" ~ owner.value ~ "'");
    }
  }

  protected override void beforeRemove(TenantId t, const Configuration e, UserId actor) {
    auto c = e.id.value;
    requireUnused("Configuration '" ~ c ~ "'",
      repos.executions.findByReference(t, "configurationId", c).count!(x => x.isActive), "active executions");
    requireUnused("Configuration '" ~ c ~ "'",
      repos.deployments.findByReference(t, "configurationId", c).count!(x => x.isActive), "active deployments");
  }

  protected long usages(TenantId t, string id) {
    return repos.executions.countByReference(t, "configurationId", id) + repos.deployments.countByReference(t,
      "configurationId", id);
  }
}

class ManageExecutionsUseCase : ResourceInteractor!(Execution, ExecutionId, ExecutionInput), IManageExecutions {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Execution, ExecutionId) store() {
    return repos.executions;
  }

  protected override string what() {
    return "Execution";
  }

  protected override string eventPrefix() {
    return "execution";
  }

  protected override string[] immutableAttributes() {
    return ["configurationId", "resourceGroupId"];
  }

  protected override ExecutionInput toInput(const Execution e) {
    return ExecutionInput(e.configurationId.value, e.resourceGroupId.value);
  }

  protected override void fromInput(TenantId t, ref Execution e, ExecutionInput i, bool creating) {
    if (!creating)
      return;
    auto cfg = configurationOf(t, i.configurationId);
    auto c = connectionOf(t, cfg.connectionId.value);
    c.requireActive("Starting an execution");
    auto g = resourceGroupFor(t, c, i.resourceGroupId, "Starting an execution");
    e.configurationId = cfg.id;
    e.scenarioId = cfg.scenarioId;
    e.connectionId = c.id;
    e.resourceGroupId = g.id;
    e.status = ExecutionStatus.pending;
    e.statusMessage = "Waiting for the runtime";
  }

  protected override void beforeRemove(TenantId t, const Execution e, UserId actor) {
    if (e.isActive)
      throw AilpException.ruleViolation("Execution '" ~ e.id.value ~ "' is " ~ cast(string) e.status ~ ": stop it first");
  }

  Execution stop(TenantId t, ExecutionId id, UserId actor) {
    auto e = get(t, id);
    e.stop(now, actor.value);
    stampUpdated(e, actor, now);
    repos.executions.save(e);
    emit("execution.stopped", t, actor, id.value);
    return e;
  }
}

class ManageDeploymentsUseCase : ResourceInteractor!(Deployment, DeploymentId, DeploymentInput), IManageDeployments {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Deployment, DeploymentId) store() {
    return repos.deployments;
  }

  protected override string what() {
    return "Deployment";
  }

  protected override string eventPrefix() {
    return "deployment";
  }

  protected override string[] immutableAttributes() {
    return ["configurationId", "resourceGroupId"];
  }

  protected override DeploymentInput toInput(const Deployment e) {
    return DeploymentInput(e.configurationId.value, e.resourceGroupId.value, e.minReplicas, e.maxReplicas, e.ttlMinutes);
  }

  protected override void fromInput(TenantId t, ref Deployment e, DeploymentInput i, bool creating) {
    if (creating) {
      auto cfg = configurationOf(t, i.configurationId);
      auto c = connectionOf(t, cfg.connectionId.value);
      c.requireActive("Creating a deployment");
      auto g = resourceGroupFor(t, c, i.resourceGroupId, "Creating a deployment");
      e.configurationId = cfg.id;
      e.scenarioId = cfg.scenarioId;
      e.connectionId = c.id;
      e.resourceGroupId = g.id;
      e.status = DeploymentStatus.pending;
      e.statusMessage = "Waiting for the runtime";
    }
    e.minReplicas = i.minReplicas;
    e.maxReplicas = i.maxReplicas;
    e.ttlMinutes = i.ttlMinutes;
  }

  protected override void beforeSave(TenantId t, ref Deployment e, bool creating, const string[] changed) {
    if (!creating && changed.length && !e.isActive)
      throw AilpException.ruleViolation("Deployment '" ~ e.id.value ~ "' is " ~ cast(string) e.status
          ~ ": only pending or running deployments can be scaled");
  }

  protected override void beforeRemove(TenantId t, const Deployment e, UserId actor) {
    if (e.isActive)
      throw AilpException.ruleViolation("Deployment '" ~ e.id.value ~ "' is " ~ cast(string) e.status ~ ": stop it first");
  }

  Deployment stop(TenantId t, DeploymentId id, UserId actor) {
    auto d = get(t, id);
    d.stop(now, "Stopped by " ~ actor.value);
    stampUpdated(d, actor, now);
    repos.deployments.save(d);
    emit("deployment.stopped", t, actor, id.value);
    return d;
  }

  Deployment start(TenantId t, DeploymentId id, UserId actor) {
    auto d = get(t, id);
    auto c = connectionOf(t, d.connectionId.value);
    c.requireActive("Starting a deployment");
    resourceGroupFor(t, c, d.resourceGroupId.value, "Starting a deployment");
    d.restart();
    stampUpdated(d, actor, now);
    repos.deployments.save(d);
    emit("deployment.restarted", t, actor, id.value);
    return d;
  }
}
