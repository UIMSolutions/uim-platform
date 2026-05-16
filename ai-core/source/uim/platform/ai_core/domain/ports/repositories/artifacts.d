/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.artifacts;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.artifact;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface ArtifactRepository : ITenantRepository!(Artifact, ArtifactId) {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id);
  Artifact findById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Artifact[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);

  size_t countByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId);
  Artifact[] findByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId);
  void removeByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId);

  size_t countByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId);
  Artifact[] findByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId);
  void removeByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId);

  size_t countByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId);
  Artifact[] findByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId);
  void removeByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId);

}
