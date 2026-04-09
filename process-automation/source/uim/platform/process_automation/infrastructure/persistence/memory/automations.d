/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.automations;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryAutomationRepository : AutomationRepository {
    private Automation[] store;

    Automation findById(AutomationId id) {
        foreach (ref a; store) {
            if (a.id == id)
                return a;
        }
        return Automation.init;
    }

    Automation[] findByTenant(TenantId tenantId) {
        return store.filter!(a => a.tenantId == tenantId).array;
    }

    Automation[] findByProject(ProjectId projectId) {
        return store.filter!(a => a.projectId == projectId).array;
    }

    void save(Automation a) {
        store ~= a;
    }

    void update(Automation a) {
        foreach (ref existing; store) {
            if (existing.id == a.id) {
                existing = a;
                return;
            }
        }
    }

    void remove(AutomationId id) {
        store = store.filter!(a => a.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(a => a.tenantId == tenantId).array.length;
    }
}
