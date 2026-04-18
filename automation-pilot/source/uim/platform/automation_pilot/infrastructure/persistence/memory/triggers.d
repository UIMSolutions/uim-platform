/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryTriggerRepository : TriggerRepository {
    private Trigger[] store;

    bool existsById(TriggerId id) {
        return store.any!(e => e.id == id);
    }

    Trigger findById(TriggerId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Trigger.init;
    }

    Trigger[] findAll() { return store; }

    Trigger[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Trigger[] findByCommand(CommandId commandId) {
        return store.filter!(e => e.commandId == commandId).array;
    }

    Trigger[] findByStatus(TriggerStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(Trigger trigger) { store ~= trigger; }

    void update(Trigger trigger) {
        foreach (ref e; store)
            if (e.id == trigger.id) { e = trigger; return; }
    }

    void remove(TriggerId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
