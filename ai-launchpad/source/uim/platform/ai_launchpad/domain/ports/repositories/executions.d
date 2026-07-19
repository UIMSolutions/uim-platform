/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.executions;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.execution : Execution;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

interface IExecutionRepository : ITenantRepository!(Execution, ExecutionId) {

  bool existsById(TenantId tenantId, ConnectionId connectionId, ExecutionId id );
  Execution findById(TenantId tenantId, ConnectionId connectionId, ExecutionId id);
  void removeById(TenantId tenantId, ConnectionId connectionId, ExecutionId id);
  
  size_t countByConnection(TenantId tenantId, ConnectionId connectionId);
  Execution[] findByConnection(TenantId tenantId, ConnectionId connectionId);
  void removeByConnection(TenantId tenantId, ConnectionId connectionId);

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  Execution[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  size_t countByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status);
  Execution[] findByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status);
  void removeByStatus(TenantId tenantId, ConnectionId connectionId, ExecutionStatus status);

}
