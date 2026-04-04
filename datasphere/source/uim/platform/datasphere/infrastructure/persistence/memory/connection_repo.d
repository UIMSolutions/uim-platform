/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.connection_repo;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.connection;
import uim.platform.datasphere.domain.ports.repositories.connections;

import std.algorithm : filter;
import std.array : array;

class MemoryConnectionRepository : ConnectionRepository {
  private Connection[][string] store;

  Connection findById(ConnectionId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ref c; *sp) {
        if (c.id == id)
          return c;
      }
    }
    return Connection.init;
  }

  Connection[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  Connection[] findByType(ConnectionType type, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(c => c.type == type).array;
    return [];
  }

  void save(Connection c) {
    store[c.spaceId] ~= c;
  }

  void update(Connection c) {
    if (auto sp = c.spaceId in store) {
      foreach (ref existing; *sp) {
        if (existing.id == c.id) {
          existing = c;
          return;
        }
      }
    }
  }

  void remove(ConnectionId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(c => c.id != id).array;
    }
  }

  long countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return cast(long)(*sp).length;
    return 0;
  }
}
