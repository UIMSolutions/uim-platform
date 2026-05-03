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
    bool existsById(AutomationId id) {
        return findAll().any!(a => a.id == id);
    }
    Automation findById(AutomationId id) {
        foreach (a; findAll()) {
            if (a.id == id)
                return a;
        }
        return Automation.init;
    }
    void removeById(AutomationId id) {
        foreach (a; findAll()   ) {
            if (a.id == id) {
                remove(a);
                return;
            }
        }
    }

    size_t countByProject(ProjectId projectId) {
        return findByProject(projectId).length;
    }
    Automation[] findByProject(ProjectId projectId) {
        return findAll().filter!(a => a.projectId == projectId).array;
    }
    void removeByProject(ProjectId projectId) {
        findByProject(projectId).each!(a => store.remove(a));
    }

}
