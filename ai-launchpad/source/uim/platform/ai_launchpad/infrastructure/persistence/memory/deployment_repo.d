/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.deployment_repo;

import uim.platform.ai_launchpad.domain.ports.repositories.deployments;
import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
import uim.platform.ai_launchpad.domain.types;

class MemoryDeploymentRepository : IDeploymentRepository {
  private Deployment[] store;

  void save(Deployment d) {
    foreach (ref existing; store) {
      if (existing.id == d.id && existing.connectionId == d.connectionId) {
        existing = d;
        return;
      }
    }
    store ~= d;
  }

  Deployment findById(DeploymentId id, ConnectionId connectionId) {
    foreach (ref d; store) {
      if (d.id == id && d.connectionId == connectionId) return d;
    }
    return Deployment.init;
  }

  Deployment[] findByConnection(ConnectionId connectionId) {
    Deployment[] result;
    foreach (ref d; store) {
      if (d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Deployment[] result;
    foreach (ref d; store) {
      if (d.scenarioId == scenarioId && d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findByStatus(DeploymentStatus status, ConnectionId connectionId) {
    Deployment[] result;
    foreach (ref d; store) {
      if (d.status == status && d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findAll() {
    return store.dup;
  }

  void remove(DeploymentId id, ConnectionId connectionId) {
    Deployment[] filtered;
    foreach (ref d; store) {
      if (!(d.id == id && d.connectionId == connectionId)) filtered ~= d;
    }
    store = filtered;
  }
}
