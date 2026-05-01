/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.remote_table;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.remote_table;
// import uim.platform.datasphere.domain.ports.repositories.remote_tables;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryRemoteTableRepository : RemoteTableRepository {
  private RemoteTable[][SpaceId] store;

  RemoteTable findById(RemoteTableId id, SpaceId spaceId) {
    if (spaceId in store) {
      foreach (rt; store[spaceId]) {
        if (rt.id == id)
          return rt;
      }
    }
    return RemoteTable.init;
  }

  RemoteTable[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  RemoteTable[] findByConnection(ConnectionId connId, SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].filter!(rt => rt.connectionId == connId).array;
    return null;
  }

  void save(RemoteTable rt) {
    store[rt.spaceId] ~= rt;
  }

  void update(RemoteTable rt) {
    if (rt.spaceId in store) {
      foreach (existing; store[rt.spaceId]) {
        if (existing.id == rt.id) {
          existing = rt;
          return;
        }
      }
    }
  }

  void remove(RemoteTableId id, SpaceId spaceId) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(rt => rt.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
