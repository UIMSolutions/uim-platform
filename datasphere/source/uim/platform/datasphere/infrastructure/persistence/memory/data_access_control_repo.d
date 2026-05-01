/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_access_control;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.data_access_control;
// import uim.platform.datasphere.domain.ports.repositories.data_access_controls;

// import std.algorithm : filter, canFind;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryDataAccessControlRepository : DataAccessControlRepository {
  private DataAccessControl[][SpaceId] store;

  DataAccessControl findById(SpaceId spaceId, DataAccessControlId id) {
    if (spaceId in store) {
      foreach (dac; store[spaceId]) {
        if (dac.id == id)
          return dac;
      }
    }
    return DataAccessControl.init;
  }

  DataAccessControl[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  DataAccessControl[] findByView(SpaceId spaceId, ViewId viewId) {
    if (spaceId in store)
      return store[spaceId].filter!(dac => dac.targetViewIds.any!(id => id == viewId)).array;
    return null;
  }

  void save(DataAccessControl dac) {
    store[dac.spaceId] ~= dac;
  }

  void update(DataAccessControl dac) {
    if (dac.spaceId in store) {
      foreach (existing; store[dac.spaceId]) {
        if (existing.id == dac.id) {
          existing = dac;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, DataAccessControlId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(dac => dac.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
