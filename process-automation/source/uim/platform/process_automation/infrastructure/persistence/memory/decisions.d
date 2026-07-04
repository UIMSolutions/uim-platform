/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.decisions;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryDecisionRepository : TenantRepository!(Decision, DecisionId), DecisionRepository {

    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }

    Decision[] findByProject(TenantId tenantId, ProjectId projectId) {
        return filterByProject(findByTenant(tenantId), projectId);
    }

    Decision[] filterByProject(Decision[] decisions, ProjectId projectId) {
        return decisions.filter!(d => d.projectId == projectId).array;
    }

    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(d => remove(d));
    }

}
