/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_access_control;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.data_access_control;
import uim.platform.datasphere.domain.ports.repositories.data_access_controls;

import std.algorithm : filter, canFind;
import std.array : array;

class MemoryDataAccessControlRepository : DataAccessControlRepository {
  private DataAccessControl[][string] store;

  DataAccessControl findById(DataAccessControlId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (dac; *sp) {
        if (dac.id == id)
          return dac;
      }
    }
    return DataAccessControl.init;
  }

  DataAccessControl[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  DataAccessControl[] findByView(ViewId viewId, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(dac => dac.targetViewIds.canFind(viewId)).array;
    return [];
  }

  void save(DataAccessControl dac) {
    store[dac.spaceId] ~= dac;
  }

  void update(DataAccessControl dac) {
    if (auto sp = dac.spaceId in store) {
      foreach (existing; *sp) {
        if (existing.id == dac.id) {
          existing = dac;
          return;
        }
      }
    }
  }

  void remove(DataAccessControlId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(dac => dac.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
