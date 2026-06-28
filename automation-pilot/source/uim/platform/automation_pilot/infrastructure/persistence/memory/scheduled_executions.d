/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.scheduled_executions;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class MemoryScheduledExecutionRepository : TenantRepository!(ScheduledExecution, ScheduledExecutionId), ScheduledExecutionRepository {

    size_t countByCommand(TenantId tenantId, CommandId commandId) {
        return findByCommand(tenantId, commandId).length;
    }

    ScheduledExecution[] filterByCommand(ScheduledExecution[] executions, CommandId commandId) {
        return executions.filter!(e => e.commandId == commandId).array;
    }

    ScheduledExecution[] findByCommand(TenantId tenantId, CommandId commandId) {
        return filterByCommand(find(tenantId), commandId);
    }

    void removeByCommand(TenantId tenantId, CommandId commandId) {
        findByCommand(tenantId, commandId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, ScheduleStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ScheduledExecution[] filterByStatus(ScheduledExecution[] executions, ScheduleStatus status) {
        return executions.filter!(e => e.status == status).array;
    }

    ScheduledExecution[] findByStatus(TenantId tenantId, ScheduleStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ScheduleStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
