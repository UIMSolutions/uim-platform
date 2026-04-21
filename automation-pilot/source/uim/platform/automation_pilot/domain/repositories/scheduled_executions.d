/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ScheduledExecutionRepository : ITenantRepository!(ScheduledExecution, ScheduledExecutionId) {
    
    size_t countByCommand(CommandId commandId);
    ScheduledExecution[] findByCommand(CommandId commandId);
    void removeByCommand(CommandId commandId);

    size_t countByStatus(ScheduleStatus status);
    ScheduledExecution[] findByStatus(ScheduleStatus status);
    void removeByStatus(ScheduleStatus status);

}
