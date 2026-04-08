/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.connection;

import uim.platform.ai_launchpad.domain.ports.repositories.connections;
import uim.platform.ai_launchpad.domain.entities.connection : Connection;
import uim.platform.ai_launchpad.domain.types;

class MemoryConnectionRepository : IConnectionRepository {
  private Connection[string] store;

  void save(Connection c) {
    store[c.id] = c;
  }

  Connection findById(ConnectionId id) {
    if (auto p = id in store) return *p;
    return Connection.init;
  }

  Connection[] findByWorkspace(WorkspaceId workspaceId) {
    Connection[] result;
    foreach (ref c; store) {
      if (c.workspaceId == workspaceId) result ~= c;
    }
    return result;
  }

  Connection[] findAll() {
    return store.values;
  }

  void remove(ConnectionId id) {
    store.remove(id);
  }
}
