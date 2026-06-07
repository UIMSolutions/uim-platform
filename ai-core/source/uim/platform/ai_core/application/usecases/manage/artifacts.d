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



import uim.platform.ai_core;

// mixin(ShowModule!()); 

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

    repo.save(a);
    return CommandResult(true, a.id.value, "");
  }

  Artifact getArtifact(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactId artifactId) {
    return repo.findById(tenantId, resourceGroupId, artifactId);
  }

  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return repo.findByResourceGroup(tenantId, resourceGroupId);
  }

  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId) {
    return repo.findByScenario(tenantId, resourceGroupId, scenarioId);
  }

  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactKind kind) {
    return repo.findByKind(tenantId, resourceGroupId, kind);
  }

  Artifact[] listArtifacts(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId) {
    return repo.findByExecution(tenantId, resourceGroupId, executionId);
  }

  CommandResult deleteArtifact(TenantId tenantId, ResourceGroupId resourceGroupId, ArtifactId artifactId) {
    auto artifact = repo.findById(tenantId, resourceGroupId, artifactId);
    if (artifact.isNull)
      return CommandResult(false, "", "Artifact not found");

    repo.remove(artifact);
    return CommandResult(true, artifact.id.value, "");
  }

  size_t count(TenantId tenantId, ResourceGroupId resourceGroupId) {
    return repo.countByResourceGroup(tenantId, resourceGroupId);
  }
}
