/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.remote_table;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.remote_table;
import uim.platform.datasphere.domain.ports.repositories.remote_tables;

import std.algorithm : filter;
import std.array : array;

class MemoryRemoteTableRepository : RemoteTableRepository {
  private RemoteTable[][string] store;

  RemoteTable findById(RemoteTableId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (rt; *sp) {
        if (rt.id == id)
          return rt;
      }
    }
    return RemoteTable.init;
  }

  RemoteTable[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  RemoteTable[] findByConnection(ConnectionId connId, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(rt => rt.connectionId == connId).array;
    return [];
  }

  void save(RemoteTable rt) {
    store[rt.spaceId] ~= rt;
  }

  void update(RemoteTable rt) {
    if (auto sp = rt.spaceId in store) {
      foreach (existing; *sp) {
        if (existing.id == rt.id) {
          existing = rt;
          return;
        }
      }
    }
  }

  void remove(RemoteTableId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(rt => rt.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).length;
    return 0;
  }
}
