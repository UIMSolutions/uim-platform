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
    private Decision[] store;

    Decision findById(DecisionId id) {
        foreach (d; findAll) {
            if (d.id == id)
                return d;
        }
        return Decision.init;
    }

    Decision[] findByTenant(TenantId tenantId) {
        return findAll().filter!(d => d.tenantId == tenantId).array;
    }

    Decision[] findByProject(ProjectId projectId) {
        return findAll().filter!(d => d.projectId == projectId).array;
    }


}
