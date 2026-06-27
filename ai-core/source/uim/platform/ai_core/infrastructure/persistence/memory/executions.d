/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.executions;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.execution;
// import uim.platform.ai_core.domain.ports.repositories.executions;

import uim.platform.ai_core;

// mixin(ShowModule!());

@safe:
class MemoryExecutionRepository : TentRepository!(Execution, ExecutionId), ExecutionRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id) {
    return findByResourceGroup(tenantId, rgId).any!(e => e.id == id);
  }

  Execution findById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id) {
    auto executions = findByResourceGroup(tenantId, rgId);
    foreach (e; executions) {
      if (e.id == id) {
        return e;
      }
    }
    return Execution.init;
  }

  void removeById(TenantId tenantId, ResourceGroupId rgId, ExecutionId id) {
    auto execution = findById(tenantId, rgId, id);
    remove(execution);
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Execution[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(e => remove(e));
  }

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return findByScenario(tenantId, rgId, scenarioId).length;
  }

  Execution[] filterByScenario(Execution[] executions, ScenarioId scenarioId) {
    return executions.filter!(e => e.scenarioId == scenarioId).array;
  }

  Execution[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    findByScenario(tenantId, rgId, scenarioId).each!(e => remove(e));
  }

  size_t countByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    return findByConfiguration(tenantId, rgId, confId).length;
  }

  Execution[] filterByConfiguration(Execution[] executions, ConfigurationId confId) {
    return executions.filter!(e => e.configurationId == confId).array;
  }

  Execution[] findByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    return filterByConfiguration(findByResourceGroup(tenantId, rgId), confId);
  }

  void removeByConfiguration(TenantId tenantId, ResourceGroupId rgId, ConfigurationId confId) {
    findByConfiguration(tenantId, rgId, confId).each!(e => remove(e));
  }

  size_t countByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    return findByExecutable(tenantId, rgId, execId).length;
  }

  Execution[] filterByExecutable(Execution[] executions, ExecutableId execId) {
    return executions.filter!(e => e.executableId == execId).array;
  }

  Execution[] findByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    return filterByExecutable(findByResourceGroup(tenantId, rgId), execId);
  }

  void removeByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    findByExecutable(tenantId, rgId, execId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status) {
    return findByStatus(tenantId, rgId, status).length;
  }

  Execution[] filterByStatus(Execution[] executions, ExecutionStatus status) {
    return executions.filter!(e => e.status == status).array;
  }
  Execution[] findByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status) {
    return filterByStatus(findByResourceGroup(tenantId, rgId), status);
  }

  void removeByStatus(TenantId tenantId, ResourceGroupId rgId, ExecutionStatus status) {
    findByStatus(tenantId, rgId, status).each!(e => remove(e));
  }

}
