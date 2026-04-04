/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.scenarios;

import uim.platform.ai_launchpad.domain.ports.repositories.scenarios;
import uim.platform.ai_launchpad.domain.entities.scenario : Scenario;
import uim.platform.ai_launchpad.domain.types;

class MemoryScenarioRepository : IScenarioRepository {
  private Scenario[] store;

  void save(Scenario s) {
    foreach (ref existing; store) {
      if (existing.id == s.id && existing.connectionId == s.connectionId) {
        existing = s;
        return;
      }
    }
    store ~= s;
  }

  Scenario findById(ScenarioId id, ConnectionId connectionId) {
    foreach (ref s; store) {
      if (s.id == id && s.connectionId == connectionId) return s;
    }
    return Scenario.init;
  }

  Scenario[] findByConnection(ConnectionId connectionId) {
    Scenario[] result;
    foreach (ref s; store) {
      if (s.connectionId == connectionId) result ~= s;
    }
    return result;
  }

  Scenario[] findAll() {
    return store.dup;
  }

  void remove(ScenarioId id, ConnectionId connectionId) {
    Scenario[] filtered;
    foreach (ref s; store) {
      if (!(s.id == id && s.connectionId == connectionId)) filtered ~= s;
    }
    store = filtered;
  }
}
