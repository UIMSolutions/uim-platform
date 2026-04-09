/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.task;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.task;
import uim.platform.datasphere.domain.ports.repositories.tasks;

import std.algorithm : filter;
import std.array : array;

class MemoryTaskRepository : TaskRepository {
  private Task[][string] store;

  Task findById(TaskId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ref t; *sp) {
        if (t.id == id)
          return t;
      }
    }
    return Task.init;
  }

  Task[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  Task[] findByStatus(TaskStatus status, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(t => t.status == status).array;
    return [];
  }

  Task[] findByType(TaskType type, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(t => t.type == type).array;
    return [];
  }

  void save(Task t) {
    store[t.spaceId] ~= t;
  }

  void update(Task t) {
    if (auto sp = t.spaceId in store) {
      foreach (ref existing; *sp) {
        if (existing.id == t.id) {
          existing = t;
          return;
        }
      }
    }
  }

  void remove(TaskId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(t => t.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
