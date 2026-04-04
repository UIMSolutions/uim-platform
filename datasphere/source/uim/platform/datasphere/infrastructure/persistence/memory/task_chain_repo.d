/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.task_chain_repo;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.task_chain;
import uim.platform.datasphere.domain.ports.repositories.task_chains;

import std.algorithm : filter;
import std.array : array;

class MemoryTaskChainRepository : TaskChainRepository {
  private TaskChain[][string] store;

  TaskChain findById(TaskChainId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ref tc; *sp) {
        if (tc.id == id)
          return tc;
      }
    }
    return TaskChain.init;
  }

  TaskChain[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  TaskChain[] findByStatus(TaskStatus status, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(tc => tc.status == status).array;
    return [];
  }

  void save(TaskChain tc) {
    store[tc.spaceId] ~= tc;
  }

  void update(TaskChain tc) {
    if (auto sp = tc.spaceId in store) {
      foreach (ref existing; *sp) {
        if (existing.id == tc.id) {
          existing = tc;
          return;
        }
      }
    }
  }

  void remove(TaskChainId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(tc => tc.id != id).array;
    }
  }

  long countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
