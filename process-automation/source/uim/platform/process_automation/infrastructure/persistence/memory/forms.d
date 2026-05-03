/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.forms;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryFormRepository : TenantRepository!(Form, FormId), FormRepository {

    size_t countByProject(ProjectId projectId) {
        return findByProject(projectId).length;
    }
    Form[] findByProject(ProjectId projectId) {
        return findAll().filter!(f => f.projectId == projectId).array;
    }
    void removeByProject(ProjectId projectId) {
        findByProject(projectId).each!(f => remove(f));
    }

}
