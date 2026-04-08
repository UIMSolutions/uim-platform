/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.view;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.view_;
import uim.platform.datasphere.domain.ports.repositories.views;

import std.algorithm : filter;
import std.array : array;

class MemoryViewRepository : ViewRepository {
  private View[][string] store;

  View findById(ViewId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ref v; *sp) {
        if (v.id == id)
          return v;
      }
    }
    return View.init;
  }

  View[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  View[] findBySemantic(ViewSemantic semantic, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(v => v.semantic == semantic).array;
    return [];
  }

  View[] findExposed(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(v => v.isExposed).array;
    return [];
  }

  void save(View v) {
    store[v.spaceId] ~= v;
  }

  void update(View v) {
    if (auto sp = v.spaceId in store) {
      foreach (ref existing; *sp) {
        if (existing.id == v.id) {
          existing = v;
          return;
        }
      }
    }
  }

  void remove(ViewId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(v => v.id != id).array;
    }
  }

  long countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
