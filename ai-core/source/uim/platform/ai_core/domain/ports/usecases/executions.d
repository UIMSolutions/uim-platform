/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.usecases.executions;

import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
interface IManageExecutionsUseCase { 

  CommandResult createExecution(CreateExecutionRequest r);
  CommandResult patchExecution(PatchExecutionRequest r);
  Execution getExecution(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId);
  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId);
  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId, ScenarioId scenarioId);
  Execution[] listExecutions(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionStatus status);
  size_t countExecutions(TenantId tenantId, ResourceGroupId resourceGroupId);
  CommandResult deleteExecution(TenantId tenantId, ResourceGroupId resourceGroupId, ExecutionId executionId);

}
