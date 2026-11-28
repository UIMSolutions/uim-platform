/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The model and dataset registry of the scenarios.
///
/// Model name + version are unique per scenario. A model that names its
/// producing execution needs a completed execution of the same scenario.
/// Artifacts still bound as input of a configuration cannot be deleted or
/// archived.
module uim.platform.ai_launchpad.application.usecases.registry;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// Number of configurations binding the artifact as input.
private long boundBy(AilpRepositories repos, TenantId t, ScenarioId scenario, string artifact) {
  return repos.configurations.findByReference(t, "scenarioId", scenario.value).count!(c => c.artifactIds.canFind(artifact));
}

class ManageModelsUseCase : ResourceInteractor!(Model, ModelId, ModelInput), IManageModels {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Model, ModelId) store() {
    return repos.models;
  }

  protected override string what() {
    return "Model";
  }

  protected override string eventPrefix() {
    return "model";
  }

  protected override string[] immutableAttributes() {
    return ["scenarioId", "executionId"];
  }

  protected override ModelInput toInput(const Model e) {
    return ModelInput(e.scenarioId.value, e.executionId, e.name, e.version_, e.description, e.url, e.sizeMiB,
      cast(string) e.status, e.labels.dup);
  }

  protected override void fromInput(TenantId t, ref Model e, ModelInput i, bool creating) {
    if (creating) {
      e.scenarioId = scenarioOf(t, i.scenarioId).id;
      e.executionId = i.executionId.strip;
      if (e.executionId.length) {
        auto x = required(repos.executions.findById(t, ExecutionId(e.executionId)), "Execution '" ~ e.executionId ~ "'");
        if (x.status != ExecutionStatus.completed)
          throw AilpException.ruleViolation("Execution '" ~ e.executionId ~ "' is " ~ cast(string) x.status
              ~ ": only completed executions produce models");
        if (x.scenarioId != e.scenarioId)
          throw AilpException.ruleViolation("Execution '" ~ e.executionId ~ "' belongs to scenario '" ~ x.scenarioId.value ~ "'");
      }
    }
    e.name = i.name.strip;
    e.version_ = i.version_.strip;
    e.description = i.description.strip;
    e.url = i.url.strip;
    e.sizeMiB = i.sizeMiB;
    e.status = parseDomainEnumOr!ArtifactStatus(i.status, ArtifactStatus.available, "model status");
    e.labels = i.labels.map!(x => x.strip).filter!(x => x.length > 0).array;
  }

  protected override void beforeSave(TenantId t, ref Model e, bool creating, const string[] changed) {
    foreach (other; repos.models.findByReference(t, "scenarioId", e.scenarioId.value))
      if (other.id != e.id && other.name == e.name && other.version_ == e.version_)
        throw AilpException.conflict("Scenario '" ~ e.scenarioId.value ~ "' already has model '" ~ e.name ~ "' version "
            ~ e.version_);
    if (!creating && changed.canFind("status") && e.status == ArtifactStatus.archived)
      requireUnused("Model '" ~ e.id.value ~ "'", boundBy(repos, t, e.scenarioId, e.id.value), "configurations");
  }

  protected override void beforeRemove(TenantId t, const Model e, UserId actor) {
    requireUnused("Model '" ~ e.id.value ~ "'", boundBy(repos, t, e.scenarioId, e.id.value), "configurations");
  }
}

class ManageDatasetsUseCase : ResourceInteractor!(Dataset, DatasetId, DatasetInput), IManageDatasets {
  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IAilpRepository!(Dataset, DatasetId) store() {
    return repos.datasets;
  }

  protected override string what() {
    return "Dataset";
  }

  protected override string eventPrefix() {
    return "dataset";
  }

  protected override string[] immutableAttributes() {
    return ["scenarioId"];
  }

  protected override DatasetInput toInput(const Dataset e) {
    return DatasetInput(e.scenarioId.value, e.name, e.description, e.url, e.sizeMiB, cast(string) e.status, e.labels.dup);
  }

  protected override void fromInput(TenantId t, ref Dataset e, DatasetInput i, bool creating) {
    if (creating)
      e.scenarioId = scenarioOf(t, i.scenarioId).id;
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.url = i.url.strip;
    e.sizeMiB = i.sizeMiB;
    e.status = parseDomainEnumOr!ArtifactStatus(i.status, ArtifactStatus.available, "dataset status");
    e.labels = i.labels.map!(x => x.strip).filter!(x => x.length > 0).array;
  }

  protected override void beforeSave(TenantId t, ref Dataset e, bool creating, const string[] changed) {
    if (!creating && changed.canFind("status") && e.status == ArtifactStatus.archived)
      requireUnused("Dataset '" ~ e.id.value ~ "'", boundBy(repos, t, e.scenarioId, e.id.value), "configurations");
  }

  protected override void beforeRemove(TenantId t, const Dataset e, UserId actor) {
    requireUnused("Dataset '" ~ e.id.value ~ "'", boundBy(repos, t, e.scenarioId, e.id.value), "configurations");
  }
}
