/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.artifacts;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.artifact;
// import uim.platform.ai_core.domain.ports.repositories.artifacts;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class MemoryArtifactRepository : TenantRepository!(Artifact, ArtifactId), ArtifactRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id) {
    return findByResourceGroup(tenantId, rgId).any!(a => a.id == id);
  }
  Artifact findById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id) {
    auto artifacts = findByResourceGroup(tenantId, rgId);
    foreach (a; artifacts) {
      if (a.id == id) {
        return a;
      }
    }
    return Artifact.init;
  }
  void removeById(TenantId tenantId, ResourceGroupId rgId, ArtifactId id) {
    remove(findById(tenantId, rgId, id));
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Artifact[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(a => remove(a));
  }

  size_t countByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId) {
    return findByScenario(tenantId, scenarioId, rgId).length;
  }

  Artifact[] filterByScenario(Artifact[] artifacts, ScenarioId scenarioId) {
    return artifacts.filter!(a => a.scenarioId == scenarioId).array;
  }

  Artifact[] findByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId) {
    findByScenario(tenantId, scenarioId, rgId).each!(a => remove(a));
  }

  size_t countByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId) {
    return findByExecution(tenantId, execId, rgId).length;
  }

  Artifact[] filterByExecution(Artifact[] artifacts, ExecutionId execId) {
    return artifacts.filter!(a => a.executionId == execId).array;
  }

  Artifact[] findByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId) {
    return filterByExecution(findByResourceGroup(tenantId, rgId), execId);
  }

  void removeByExecution(TenantId tenantId, ExecutionId execId, ResourceGroupId rgId) {
    findByExecution(tenantId, execId, rgId).each!(a => remove(a));
  }

  size_t countByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId) {
    return findByKind(tenantId, kind, rgId).length;
  }

  Artifact[] filterByKind(Artifact[] artifacts, ArtifactKind kind) {
    return artifacts.filter!(a => a.kind == kind).array;
  }
  
  Artifact[] findByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId) {
    return filterByKind(findByResourceGroup(tenantId, rgId), kind);
  }

  void removeByKind(TenantId tenantId, ArtifactKind kind, ResourceGroupId rgId) {
    findByKind(tenantId, kind, rgId).each!(a => remove(a));
  }

}
