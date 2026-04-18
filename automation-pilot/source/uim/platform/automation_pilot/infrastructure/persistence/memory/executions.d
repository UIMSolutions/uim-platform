/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryExecutionRepository : ExecutionRepository {
    private Execution[] store;

    bool existsById(ExecutionId id) {
        return store.any!(e => e.id == id);
    }

    Execution findById(ExecutionId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Execution.init;
    }

    Execution[] findAll() { return store; }

    Execution[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Execution[] findByCommand(CommandId commandId) {
        return store.filter!(e => e.commandId == commandId).array;
    }

    Execution[] findByStatus(ExecutionStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Execution execution) { store ~= execution; }

    void update(Execution execution) {
        foreach (ref e; store)
            if (e.id == execution.id) { e = execution; return; }
    }

    void remove(ExecutionId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
