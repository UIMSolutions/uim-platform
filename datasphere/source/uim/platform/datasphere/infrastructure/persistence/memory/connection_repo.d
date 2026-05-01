/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.connection;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.connection;
// import uim.platform.datasphere.domain.ports.repositories.connections;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryConnectionRepository : ConnectionRepository {
  private Connection[][SpaceId] store;

  Connection findById(SpaceId spaceId, ConnectionId id) {
    if (spaceId in store) {
      foreach (c; store[spaceId]) {
        if (c.id == id)
          return c;
      }
    }
    return Connection.init;
  }

  Connection[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  Connection[] findByType(SpaceId spaceId, ConnectionType type) {
    if (spaceId in store)
      return store[spaceId].filter!(c => c.type == type).array;
    return null;
  }

  void save(Connection c) {
    store[c.spaceId] ~= c;
  }

  void update(Connection c) {
    if (c.spaceId in store) {
      foreach (existing; store[c.spaceId]) {
        if (existing.id == c.id) {
          existing = c;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, ConnectionId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(c => c.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
