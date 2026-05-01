/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.task_chain;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.task_chain;
// import uim.platform.datasphere.domain.ports.repositories.task_chains;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryTaskChainRepository : TaskChainRepository {
  private TaskChain[][SpaceId] store;

  TaskChain findById(SpaceId spaceId, TaskChainId id) {
    if (spaceId in store) {
      foreach (tc; store[spaceId]) {
        if (tc.id == id)
          return tc;
      }
    }
    return TaskChain.init;
  }

  TaskChain[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  TaskChain[] findByStatus(SpaceId spaceId, TaskStatus status) {
    if (spaceId in store)
      return store[spaceId].filter!(tc => tc.status == status).array;
    return null;
  }

  void save(TaskChain tc) {
    store[tc.spaceId] ~= tc;
  }

  void update(TaskChain tc) {
    if (tc.spaceId in store) {
      foreach (existing; store[tc.spaceId]) {
        if (existing.id == tc.id) {
          existing = tc;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, TaskChainId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(tc => tc.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
