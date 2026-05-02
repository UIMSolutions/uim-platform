/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.deployment;

// import uim.platform.ai_launchpad.domain.ports.repositories.deployments;
// import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryDeploymentRepository : IDeploymentRepository {
  private Deployment[] store;

  void save(Deployment d) {
    foreach (existing; findAll) {
      if (existing.id == d.id && existing.connectionId == d.connectionId) {
        existing = d;
        return;
      }
    }
    store ~= d;
  }

  Deployment findById(DeploymentId id, ConnectionId connectionId) {
    foreach (d; findAll) {
      if (d.id == id && d.connectionId == connectionId) return d;
    }
    return Deployment.init;
  }

  Deployment[] findByConnection(ConnectionId connectionId) {
    Deployment[] result;
    foreach (d; findAll) {
      if (d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Deployment[] result;
    foreach (d; findAll) {
      if (d.scenarioId == scenarioId && d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findByStatus(DeploymentStatus status, ConnectionId connectionId) {
    Deployment[] result;
    foreach (d; findAll) {
      if (d.status == status && d.connectionId == connectionId) result ~= d;
    }
    return result;
  }

  Deployment[] findAll() {
    return store.dup;
  }

  void remove(DeploymentId id, ConnectionId connectionId) {
    Deployment[] filtered;
    foreach (d; findAll) {
      if (!(d.id == id && d.connectionId == connectionId)) filtered ~= d;
    }
    store = filtered;
  }
}
