/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.scheduled_executions;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

interface ScheduledExecutionRepository : ITentRepository!(ScheduledExecution, ScheduledExecutionId) {
    
    size_t countByCommand(TenantId tenantId, CommandId commandId);
    ScheduledExecution[] findByCommand(TenantId tenantId, CommandId commandId);
    void removeByCommand(TenantId tenantId, CommandId commandId);

    size_t countByStatus(TenantId tenantId, ScheduleStatus status);
    ScheduledExecution[] findByStatus(TenantId tenantId, ScheduleStatus status);
    void removeByStatus(TenantId tenantId, ScheduleStatus status);

}
