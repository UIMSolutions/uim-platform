/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.deployments;
// import uim.platform.ai_launchpad.domain.ports.repositories.deployments;
// import uim.platform.ai_launchpad.domain.entities.deployment : Deployment;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:
class MemoryDeploymentRepository : TenantRepository!(Deployment, DeploymentId), IDeploymentRepository {

  bool existsById(TenantId tenantId, ConnectionId connectionId, DeploymentId id) {
    return findByConnection(tenantId, connectionId).any!(d => d.id == id);
  }

  Deployment findById(TenantId tenantId, ConnectionId connectionId, DeploymentId id) {
    foreach(d; findByConnection(tenantId, connectionId)) {
      if (d.id == id) return d;
    }
    return Deployment.init;
  }

  void removeById(TenantId tenantId, ConnectionId connectionId, DeploymentId id) {
    remove(findById(tenantId, connectionId, id));
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }

  Deployment[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }

  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    foreach (d; findByConnection(tenantId, connectionId)) {
      remove(d);
    }
  }

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }

  Deployment[] filterByScenario(Deployment[] deployments, ScenarioId scenarioId) {
    return deployments.filter!(d => d.scenarioId == scenarioId).array;
  }

  Deployment[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    foreach (d; findByScenario(tenantId, connectionId, scenarioId)) {
      remove(d);
    }
  }

  size_t countByStatus(TenantId tenantId, ConnectionId connectionId, DeploymentStatus status) {
    return findByStatus(tenantId, connectionId, status).length;
  }

  Deployment[] filterByStatus(Deployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(d => d.status == status).array;
  }

  Deployment[] findByStatus(TenantId tenantId, ConnectionId connectionId, DeploymentStatus status) {
    return filterByStatus(findByConnection(tenantId, connectionId), status);
  }

  void removeByStatus(TenantId tenantId, ConnectionId connectionId, DeploymentStatus status) {
    foreach (d; findByStatus(tenantId, connectionId, status)) {
      remove(d);
    }
  }
}
