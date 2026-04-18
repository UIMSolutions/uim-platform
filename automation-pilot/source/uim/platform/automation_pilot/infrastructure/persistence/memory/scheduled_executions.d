/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryScheduledExecutionRepository : ScheduledExecutionRepository {
    private ScheduledExecution[] store;

    bool existsById(ScheduledExecutionId id) {
        return store.any!(e => e.id == id);
    }

    ScheduledExecution findById(ScheduledExecutionId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ScheduledExecution.init;
    }

    ScheduledExecution[] findAll() { return store; }

    ScheduledExecution[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ScheduledExecution[] findByCommand(CommandId commandId) {
        return store.filter!(e => e.commandId == commandId).array;
    }

    ScheduledExecution[] findByStatus(ScheduleStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(ScheduledExecution scheduledExecution) { store ~= scheduledExecution; }

    void update(ScheduledExecution scheduledExecution) {
        foreach (ref e; store)
            if (e.id == scheduledExecution.id) { e = scheduledExecution; return; }
    }

    void remove(ScheduledExecutionId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
