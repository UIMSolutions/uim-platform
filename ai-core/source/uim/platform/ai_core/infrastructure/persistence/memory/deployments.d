/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.deployments;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.deployment;
// import uim.platform.ai_core.domain.ports.repositories.deployments;

import uim.platform.ai_core;

// mixin(ShowModule!());

@safe:
class MemoryDeploymentRepository : TenantRepository!(Deployment, DeploymentId), DeploymentRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id) {
    return findByResourceGroup(tenantId, rgId).any!(d => d.id == id);
  }

  Deployment findById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id) {
    auto deployments = findByResourceGroup(tenantId, rgId);
    foreach (d; deployments) {
      if (d.id == id) {
        return d;
      }
    }
    return Deployment.init;
  }

  void removeById(TenantId tenantId, ResourceGroupId rgId, DeploymentId id) {
    auto deployment = findById(tenantId, rgId, id);
    remove(deployment);
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Deployment[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(find(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(d => remove(d));
  }

  size_t countByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    return findByConfiguration(tenantId, rgId, confId).length;
  }

  Deployment[] findByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    return findByResourceGroup(tenantId, rgId).filter!(d => d.configurationId == confId).array;
  }

  void removeByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    findByConfiguration(tenantId, rgId, confId).each!(d => remove(d));
  }

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return findByScenario(tenantId, rgId, scenarioId).length;
  }

  Deployment[] filterByScenario(Deployment[] deployments, ScenarioId scenarioId) {
    return deployments.filter!(d => d.scenarioId == scenarioId).array;
  }

  Deployment[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    findByScenario(tenantId, rgId, scenarioId).each!(d => remove(d));
  }

  size_t countByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status) {
    return findByStatus(tenantId, rgId, status).length;
  }

  Deployment[] filterByStatus(Deployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(d => d.status == status).array;
  }

  Deployment[] findByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status) {
    return filterByStatus(findByResourceGroup(tenantId, rgId), status);
  }

  void removeByStatus(TenantId tenantId, ResourceGroupId rgId, DeploymentStatus status) {
    findByStatus(tenantId, rgId, status).each!(d => remove(d));
  }

}
