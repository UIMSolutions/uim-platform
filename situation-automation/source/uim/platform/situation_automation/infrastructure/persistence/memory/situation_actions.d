/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.situation_actions;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class MemorySituationActionRepository : TenantRepository!(SituationAction, SituationActionId), SituationActionRepository {

    size_t countByType(TenantId tenantId, ActionType type) {
        return findByType(tenantId, type).length;
    }

    SituationAction[] filterByType(SituationAction[] actions, TenantId tenantId, ActionType type) {
        return actions.filter!(a => a.tenantId == tenantId && a.type == type).array;
    }

    SituationAction[] findByType(TenantId tenantId, ActionType type) {
        return findAll().filter!(a => a.tenantId == tenantId && a.type == type).array;
    }

    void removeByType(TenantId tenantId, ActionType type) {
        findByType(tenantId, type).removeAll;
    }
    
}
