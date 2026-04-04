/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.execution_repo;

import uim.platform.ai_launchpad.domain.ports.repositories.executions;
import uim.platform.ai_launchpad.domain.entities.execution : Execution;
import uim.platform.ai_launchpad.domain.types;

class MemoryExecutionRepository : IExecutionRepository {
  private Execution[] store;

  void save(Execution e) {
    foreach (ref existing; store) {
      if (existing.id == e.id && existing.connectionId == e.connectionId) {
        existing = e;
        return;
      }
    }
    store ~= e;
  }

  Execution findById(ExecutionId id, ConnectionId connectionId) {
    foreach (ref e; store) {
      if (e.id == id && e.connectionId == connectionId) return e;
    }
    return Execution.init;
  }

  Execution[] findByConnection(ConnectionId connectionId) {
    Execution[] result;
    foreach (ref e; store) {
      if (e.connectionId == connectionId) result ~= e;
    }
    return result;
  }

  Execution[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Execution[] result;
    foreach (ref e; store) {
      if (e.scenarioId == scenarioId && e.connectionId == connectionId) result ~= e;
    }
    return result;
  }

  Execution[] findByStatus(ExecutionStatus status, ConnectionId connectionId) {
    Execution[] result;
    foreach (ref e; store) {
      if (e.status == status && e.connectionId == connectionId) result ~= e;
    }
    return result;
  }

  Execution[] findAll() {
    return store.dup;
  }

  void remove(ExecutionId id, ConnectionId connectionId) {
    Execution[] filtered;
    foreach (ref e; store) {
      if (!(e.id == id && e.connectionId == connectionId)) filtered ~= e;
    }
    store = filtered;
  }
}
