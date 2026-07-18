/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.repositories.artifacts;
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

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return findByScenario(tenantId, rgId, scenarioId).length;
  }

  Artifact[] filterByScenario(Artifact[] artifacts, ScenarioId scenarioId) {
    return artifacts.filter!(a => a.scenarioId == scenarioId).array;
  }

  Artifact[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    findByScenario(tenantId, rgId, scenarioId).each!(a => remove(a));
  }

  size_t countByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    return findByExecution(tenantId, rgId, execId).length;
  }

  Artifact[] filterByExecution(Artifact[] artifacts, ExecutionId execId) {
    return artifacts.filter!(a => a.executionId == execId).array;
  }

  Artifact[] findByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    return filterByExecution(findByResourceGroup(tenantId, rgId), execId);
  }

  void removeByExecution(TenantId tenantId, ResourceGroupId rgId, ExecutionId execId) {
    findByExecution(tenantId, rgId, execId).each!(a => remove(a));
  }

  size_t countByKind(TenantId tenantId, ResourceGroupId rgId, ArtifactKind kind) {
    return findByKind(tenantId, rgId, kind).length;
  }

  Artifact[] filterByKind(Artifact[] artifacts, ArtifactKind kind) {
    return artifacts.filter!(a => a.kind == kind).array;
  }
  
  Artifact[] findByKind(TenantId tenantId, ResourceGroupId rgId, ArtifactKind kind) {
    return filterByKind(findByResourceGroup(tenantId, rgId), kind);
  }

  void removeByKind(TenantId tenantId, ResourceGroupId rgId, ArtifactKind kind) {
    findByKind(tenantId, rgId, kind).each!(a => remove(a));
  }

}
