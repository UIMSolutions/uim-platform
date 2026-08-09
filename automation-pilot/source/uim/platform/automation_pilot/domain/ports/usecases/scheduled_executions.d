/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ManageScheduledExecutionsUseCase { 

    ScheduledExecution getScheduledExecution(TenantId tenantId, ScheduledExecutionId id);
    ScheduledExecution[] listScheduledExecutions(TenantId tenantId);
    ScheduledExecution[] listScheduledExecutions(TenantId tenantId, CommandId commandId);
    CommandResult createScheduledExecution(ScheduledExecutionDTO dto);
    CommandResult updateScheduledExecution(ScheduledExecutionDTO dto);
    CommandResult deleteScheduledExecution(TenantId tenantId, ScheduledExecutionId id);

}
