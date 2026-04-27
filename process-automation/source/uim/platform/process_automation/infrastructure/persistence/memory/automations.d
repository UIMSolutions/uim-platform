/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.automations;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryAutomationRepository : TenantRepository!(Automation, AutomationId), AutomationRepository {
    private Automation[] store;

    Automation findById(AutomationId id) {
        foreach (a; findAll) {
            if (a.id == id)
                return a;
        }
        return Automation.init;
    }

    Automation[] findByTenant(TenantId tenantId) {
        return findAll().filter!(a => a.tenantId == tenantId).array;
    }

    Automation[] findByProject(ProjectId projectId) {
        return findAll().filter!(a => a.projectId == projectId).array;
    }


}
