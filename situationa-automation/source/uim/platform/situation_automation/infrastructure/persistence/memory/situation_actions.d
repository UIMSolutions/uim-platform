/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_actions;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemorySituationActionRepository : SituationActionRepository {
    private SituationAction[] store;

    SituationAction findById(SituationActionId id) {
        foreach (a; store) {
            if (a.id == id)
                return a;
        }
        return SituationAction.init;
    }

    SituationAction[] findByTenant(TenantId tenantId) {
        return store.filter!(a => a.tenantId == tenantId).array;
    }

    SituationAction[] findByType(TenantId tenantId, ActionType type) {
        return store.filter!(a => a.tenantId == tenantId && a.type == type).array;
    }

    void save(SituationAction a) {
        store ~= a;
    }

    void update(SituationAction a) {
        foreach (existing; store) {
            if (existing.id == a.id) {
                existing = a;
                return;
            }
        }
    }

    void remove(SituationActionId id) {
        store = store.filter!(a => a.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return store.filter!(a => a.tenantId == tenantId).array.length;
    }
}
