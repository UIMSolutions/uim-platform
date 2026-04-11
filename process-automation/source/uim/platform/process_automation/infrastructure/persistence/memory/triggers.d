/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.triggers;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryTriggerRepository : TriggerRepository {
    private Trigger[] store;

    Trigger findById(TriggerId id) {
        foreach (t; store) {
            if (t.id == id)
                return t;
        }
        return Trigger.init;
    }

    Trigger[] findByTenant(TenantId tenantId) {
        return store.filter!(t => t.tenantId == tenantId).array;
    }

    Trigger[] findByProcess(ProcessId processId) {
        return store.filter!(t => t.processId == processId).array;
    }

    void save(Trigger t) {
        store ~= t;
    }

    void update(Trigger t) {
        foreach (existing; store) {
            if (existing.id == t.id) {
                existing = t;
                return;
            }
        }
    }

    void remove(TriggerId id) {
        store = store.filter!(t => t.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(t => t.tenantId == tenantId).array.length;
    }
}
