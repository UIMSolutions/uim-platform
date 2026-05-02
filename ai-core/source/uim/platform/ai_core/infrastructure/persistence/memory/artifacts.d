/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.artifacts;

// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.artifact;
// import uim.platform.ai_core.domain.ports.repositories.artifacts;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class MemoryArtifactRepository : ArtifactRepository {
  private Artifact[][string] store;

  Artifact findById(ArtifactId id, ResourceGroupId rgId) {
    if (rgId in store) {
      foreach (a; store[rgId]) {
        if (a.id == id)
          return a;
      }
    }
    return Artifact.init;
  }

  Artifact[] findByScenario(ScenarioId scenarioId, ResourceGroupId rgId) {
    if (rgId in store)
      return (store[rgId]).filter!(a => a.scenarioId == scenarioId).array;
    return null;
  }

  Artifact[] findByExecution(ExecutionId execId, ResourceGroupId rgId) {
    if (rgId in store)
      return (store[rgId]).filter!(a => a.executionId == execId).array;
    return null;
  }

  Artifact[] findByKind(ArtifactKind kind, ResourceGroupId rgId) {
    if (rgId in store)
      return (store[rgId]).filter!(a => a.kind == kind).array;
    return null;
  }

  Artifact[] findByResourceGroup(ResourceGroupId rgId) {
    if (rgId in store)
      return store[rgId];
    return null;
  }

  void save(Artifact a) {
    store[a.resourceGroupId] ~= a;
  }

  void update(Artifact a) {
    if (a.resourceGroupId in store) {
      foreach (existing; store[a.resourceGroupId]) {
        if (existing.id == a.id) {
          existing = a;
          return;
        }
      }
    }
  }

  void remove(ArtifactId id, ResourceGroupId rgId) {
    if (rgId in store) {
      store[rgId] = (store[rgId]).filter!(a => a.id != id).array;
    }
  }

  size_t countByResourceGroup(ResourceGroupId rgId) {
    if (rgId in store)
      return (store[rgId]).length;
    return 0;
  }
}
