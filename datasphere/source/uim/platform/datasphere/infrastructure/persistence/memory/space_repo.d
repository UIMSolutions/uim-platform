/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.space;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.space;
import uim.platform.datasphere.domain.ports.repositories.spaces;

import std.algorithm : filter;
import std.array : array;

class MemorySpaceRepository : SpaceRepository {
  private Space[] store;

  Space findById(SpaceId id) {
    foreach (ref s; store) {
      if (s.id == id)
        return s;
    }
    return Space.init;
  }

  Space[] findByTenant(TenantId tenantId) {
    return store.filter!(s => s.tenantId == tenantId).array;
  }

  void save(Space s) {
    store ~= s;
  }

  void update(Space s) {
    foreach (ref existing; store) {
      if (existing.id == s.id) {
        existing = s;
        return;
      }
    }
  }

  void remove(SpaceId id) {
    store = store.filter!(s => s.id != id).array;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(s => s.tenantId == tenantId).array.length;
  }
}
