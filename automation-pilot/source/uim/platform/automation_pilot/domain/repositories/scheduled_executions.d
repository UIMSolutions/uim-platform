/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface ScheduledExecutionRepository {
    bool existsById(ScheduledExecutionId id);
    ScheduledExecution findById(ScheduledExecutionId id);

    ScheduledExecution[] findAll();
    ScheduledExecution[] findByTenant(TenantId tenantId);
    ScheduledExecution[] findByCommand(CommandId commandId);
    ScheduledExecution[] findByStatus(ScheduleStatus status);

    void save(ScheduledExecution scheduledExecution);
    void update(ScheduledExecution scheduledExecution);
    void remove(ScheduledExecutionId id);
}
