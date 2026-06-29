/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.actions;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class MemoryActionRepository : TenantRepository!(Action, ActionId), ActionRepository {

    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }

    Action[] filterByProject(Action[] actions, ProjectId projectId) {
        return actions.filter!(a => a.projectId == projectId).array;
    }

    Action[] findByProject(TenantId tenantId, ProjectId projectId) {
        return filterByProject(findByTenant(tenantId), projectId);
    }

    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(a => remove(a));
    }
}
