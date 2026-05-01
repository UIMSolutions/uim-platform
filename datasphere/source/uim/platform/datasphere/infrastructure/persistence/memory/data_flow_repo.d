/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_flow;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.data_flow;
// import uim.platform.datasphere.domain.ports.repositories.data_flows;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryDataFlowRepository : DataFlowRepository {
  private DataFlow[][SpaceId] store;

  DataFlow findById(SpaceId spaceId, DataFlowId id) {
    if (spaceId in store) {
      foreach (df; store[spaceId]) {
        if (df.id == id)
          return df;
      }
    }
    return DataFlow.init;
  }

  DataFlow[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  DataFlow[] findByStatus(SpaceId spaceId, FlowStatus status) {
    if (spaceId in store)
      return store[spaceId].filter!(df => df.status == status).array;
    return null;
  }

  void save(DataFlow df) {
    store[df.spaceId] ~= df;
  }

  void update(DataFlow df) {
    if (df.spaceId in store) {
      foreach (existing; store[df.spaceId]) {
        if (existing.id == df.id) {
          existing = df;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, DataFlowId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(df => df.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
