/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.artifacts;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.artifact;
// import uim.platform.ai_core.domain.ports.repositories.artifacts;
// import uim.platform.ai_core.application.dto;
// import std.uuid : randomUUID;


import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class ManageArtifactsUseCase { // TODO: UIMUseCase {
  private ArtifactRepository repo;

  this(ArtifactRepository repo) {
    this.repo = repo;
  }

  CommandResult createArtifact(CreateArtifactRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Artifact name is required");
    if (r.kind.length == 0)
      return CommandResult(false, "", "Artifact kind is required");
    if (r.scenarioId.isEmpty)
      return CommandResult(false, "", "Scenario ID is required");
    if (r.resourceGroupId.isEmpty)
      return CommandResult(false, "", "Resource group ID is required");

    Artifact a;
    a.initEntity(r.tenantId);
    a.resourceGroupId = r.resourceGroupId;
    a.scenarioId = r.scenarioId;
    a.name = r.name;
    a.description = r.description;
    a.url = r.url;

    switch (r.kind) {
    case "model":
      a.kind = ArtifactKind.model;
      break;
    case "dataset":
      a.kind = ArtifactKind.dataset;
      break;
    case "resultset":
      a.kind = ArtifactKind.resultset;
      break;
    default:
      a.kind = ArtifactKind.other;
      break;
    }

    // Parse labels
    ArtifactLabel[] labels;
    foreach (pair; r.labels) {
      if (pair.length >= 2) {
        ArtifactLabel lbl;
        lbl.key = pair[0];
        lbl.value = pair[1];
        labels ~= lbl;
      }
    }
    a.labels = labels;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    a.createdAt = now;
    a.updatedAt = now;

    repo.save(a);
    return CommandResult(true, a.id.value, "");
  }

  Artifact getArtifact(GetArtifactRequest r) {
    return repo.findById(r.resourceGroupId, r.artifactId);
  }

  Artifact[] listArtifacts(ListArtifactsRequest r) {
    return repo.findByResourceGroup(r.resourceGroupId);
  }

  Artifact[] listArtifacts(ListArtifactsByScenarioRequest r) {
    return repo.findByScenario(r.resourceGroupId, r.scenarioId);
  }

  Artifact[] listArtifacts(ListArtifactsByKindRequest r) {
    return repo.findByKind(r.resourceGroupId, r.kind);
  }

  Artifact[] listArtifacts(ListArtifactsByExecutionRequest r) {
    return repo.findByExecution(r.resourceGroupId, r.executionId);
  }

  CommandResult deleteArtifact(ResourceGroupId resourceGroupId, ArtifactId artifactId) {
    auto artifact = repo.findById(resourceGroupId, artifactId);
    if (artifact.isNull)
      return CommandResult(false, "", "Artifact not found");

    repo.remove(artifact);
    return CommandResult(true, artifact.id.value, "");
  }

  size_t count(CountArtifactsRequest r) {
    return repo.countByResourceGroup(r.resourceGroupId);
  }
}
