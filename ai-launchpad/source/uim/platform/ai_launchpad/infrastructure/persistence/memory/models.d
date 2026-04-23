/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.model;

import uim.platform.ai_launchpad.domain.ports.repositories.models;
import uim.platform.ai_launchpad.domain.entities.model : Model;
import uim.platform.ai_launchpad.domain.types;

class MemoryModelRepository : IModelRepository {
  private Model[] store;

  void save(Model m) {
    foreach (existing; store) {
      if (existing.id == m.id && existing.connectionId == m.connectionId) {
        existing = m;
        return;
      }
    }
    store ~= m;
  }

  Model findById(ModelId id, ConnectionId connectionId) {
    foreach (m; store) {
      if (m.id == id && m.connectionId == connectionId) return m;
    }
    return Model.init;
  }

  Model[] findByConnection(ConnectionId connectionId) {
    Model[] result;
    foreach (m; store) {
      if (m.connectionId == connectionId) result ~= m;
    }
    return result;
  }

  Model[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Model[] result;
    foreach (m; store) {
      if (m.scenarioId == scenarioId && m.connectionId == connectionId) result ~= m;
    }
    return result;
  }

  Model[] findAll() {
    return store.dup;
  }

  void remove(ModelId id, ConnectionId connectionId) {
    Model[] filtered;
    foreach (m; store) {
      if (!(m.id == id && m.connectionId == connectionId)) filtered ~= m;
    }
    store = filtered;
  }
}
