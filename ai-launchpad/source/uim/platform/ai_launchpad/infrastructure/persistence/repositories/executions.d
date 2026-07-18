/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.repositories.executions;
// import uim.platform.ai_launchpad.domain.ports.repositories.executions;
// import uim.platform.ai_launchpad.domain.entities.execution : Execution;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryExecutionRepository : TenantRepository!(Execution, ExecutionId), IExecutionRepository {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ExecutionId id) {
    return findByConnection(tenantId, connectionId).any!(e => e.id == id);
  }
  Execution findById(TenantId tenantId, ConnectionId connectionId, ExecutionId id) {
    foreach (e; findByConnection(tenantId, connectionId)) {
      if (e.id == id) return e;
    }
    return Execution.init;
  }
  void removeById(TenantId tenantId, ConnectionId connectionId, ExecutionId id) {
    auto execution = findById(tenantId, connectionId, id);
    remove(execution);
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  Execution[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(e => remove(e));
  }
  
  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }
  Execution[] filterByScenario(Execution[] executions, ScenarioId scenarioId) {
    return executions.filter!(e => e.scenarioId == scenarioId).array;
  }
  Execution[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    findByScenario(tenantId, connectionId, scenarioId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status) {
    return findByStatus(tenantId, connectionId, status).length;
  }
  Execution[] filterByStatus(Execution[] executions, ExecutionStatus status) {
    return executions.filter!(e => e.status == status).array;
  }
  Execution[] findByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status) {
    return filterByStatus(findByConnection(tenantId, connectionId), status);
  }
  void removeByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status) {
    findByStatus(tenantId, connectionId, status).each!(e => remove(e));
  }

}
