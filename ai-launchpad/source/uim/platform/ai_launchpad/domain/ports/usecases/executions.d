/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.executions;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageExecutionsUseCase { 

  CommandResult createExecution(CreateExecutionRequest r);

  Execution getExecution(TenantId tenantId, ConnectionId connectionId, ExecutionId id);

  Execution[] listExecutions(TenantId tenantId, ConnectionId connectionId);

  Execution[] listExecutions(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  CommandResult patchExecution(PatchExecutionRequest r);

  CommandResult[] bulkPatchExecution(BulkPatchExecutionRequest r);

  CommandResult deleteExecution(TenantId tenantId, ConnectionId connectionId, ExecutionId id);
  
}
