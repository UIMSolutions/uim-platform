/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_flow_repo;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.data_flow;
import uim.platform.datasphere.domain.ports.repositories.data_flows;

import std.algorithm : filter;
import std.array : array;

class MemoryDataFlowRepository : DataFlowRepository {
  private DataFlow[][string] store;

  DataFlow findById(DataFlowId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ref df; *sp) {
        if (df.id == id)
          return df;
      }
    }
    return DataFlow.init;
  }

  DataFlow[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  DataFlow[] findByStatus(FlowStatus status, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(df => df.status == status).array;
    return [];
  }

  void save(DataFlow df) {
    store[df.spaceId] ~= df;
  }

  void update(DataFlow df) {
    if (auto sp = df.spaceId in store) {
      foreach (ref existing; *sp) {
        if (existing.id == df.id) {
          existing = df;
          return;
        }
      }
    }
  }

  void remove(DataFlowId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(df => df.id != id).array;
    }
  }

  long countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
