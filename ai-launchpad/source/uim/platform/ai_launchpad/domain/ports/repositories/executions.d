/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.executions;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.execution : Execution;

interface IExecutionRepository {
  bool existsById(ExecutionId id, ConnectionId connectionId);
  Execution findById(ExecutionId id, ConnectionId connectionId);
  
  Execution[] findByConnection(ConnectionId connectionId);
  Execution[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  Execution[] findByStatus(ExecutionStatus status, ConnectionId connectionId);
  Execution[] findAll();

  void save(Execution e);
  void remove(ExecutionId id, ConnectionId connectionId);
}
