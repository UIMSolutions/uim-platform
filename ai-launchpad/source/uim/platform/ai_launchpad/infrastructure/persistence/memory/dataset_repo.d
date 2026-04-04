/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.dataset_repo;

import uim.platform.ai_launchpad.domain.ports.dataset_repository;
import uim.platform.ai_launchpad.domain.entities.dataset : Dataset;
import uim.platform.ai_launchpad.domain.types;

class MemoryDatasetRepository : IDatasetRepository {
  private Dataset[] store;

  void save(Dataset d) {
    foreach (ref existing; store) {
      if (existing.id == d.id && existing.connectionId == d.connectionId) {
        existing = d;
        return;
      }
    }
    store ~= d;
  }

  Dataset findById(DatasetId id, ConnectionId connectionId) {
    foreach (ref d; store) {
      if (d.id == id && d.connectionId == connectionId) return d;
    }
    return Dataset.init;
  }

  Dataset[] findByConnection(ConnectionId connectionId) {
    Dataset[] result;
    foreach (ref d; store) {
      if (d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Dataset[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Dataset[] result;
    foreach (ref d; store) {
      if (d.scenarioId == scenarioId && d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Dataset[] findAll() {
    return store.dup;
  }

  void remove(DatasetId id, ConnectionId connectionId) {
    Dataset[] filtered;
    foreach (ref d; store) {
      if (!(d.id == id && d.connectionId == connectionId)) filtered ~= d;
    }
    store = filtered;
  }
}
