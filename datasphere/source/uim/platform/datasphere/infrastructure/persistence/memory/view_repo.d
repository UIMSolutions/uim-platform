/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.view;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.view_;
// import uim.platform.datasphere.domain.ports.repositories.views;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryViewRepository : ViewRepository {
  private View[][SpaceId] store;

  View findById(SpaceId spaceId, ViewId id) {
    if (spaceId in store) {
      foreach (v; store[spaceId]) {
        if (v.id == id)
          return v;
      }
    }
    return View.init;
  }

  View[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  View[] findBySemantic(SpaceId spaceId, ViewSemantic semantic) {
    if (spaceId in store)
      return store[spaceId].filter!(v => v.semantic == semantic).array;
    return null;
  }

  View[] findExposed(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].filter!(v => v.isExposed).array;
    return null;
  }

  void save(View v) {
    store[v.spaceId] ~= v;
  }

  void update(View v) {
    if (v.spaceId in store) {
      foreach (existing; store[v.spaceId]) {
        if (existing.id == v.id) {
          existing = v;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, ViewId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(v => v.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
