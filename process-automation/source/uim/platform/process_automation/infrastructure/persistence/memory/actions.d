/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.actions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryActionRepository : ActionRepository {
    private Action[] store;

    Action findById(ActionId id) {
        foreach (ref a; store) {
            if (a.id == id)
                return a;
        }
        return Action.init;
    }

    Action[] findByTenant(TenantId tenantId) {
        return store.filter!(a => a.tenantId == tenantId).array;
    }

    Action[] findByProject(ProjectId projectId) {
        return store.filter!(a => a.projectId == projectId).array;
    }

    void save(Action a) {
        store ~= a;
    }

    void update(Action a) {
        foreach (ref existing; store) {
            if (existing.id == a.id) {
                existing = a;
                return;
            }
        }
    }

    void remove(ActionId id) {
        store = store.filter!(a => a.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(a => a.tenantId == tenantId).array.length;
    }
}
