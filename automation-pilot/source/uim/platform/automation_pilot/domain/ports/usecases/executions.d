/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface IManageExecutionsUseCase { 
    
    Execution getExecution(TenantId tenantId, ExecutionId executionId);
    Execution[] listExecutions(TenantId tenantId);
    Execution[] listExecutions(TenantId tenantId, CommandId commandId);
    Execution[] listExecutions(TenantId tenantId, ExecutionStatus status);
    CommandResult updateExecution(ExecutionDTO dto);
    CommandResult deleteExecution(TenantId tenantId, ExecutionId id);

}
