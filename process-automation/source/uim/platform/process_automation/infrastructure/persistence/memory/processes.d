/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.processes;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryProcessRepository : TenantRepository!(Process, ProcessId), ProcessRepository {
    size_t countByProject(ProjectId projectId) {
        return findByProject(projectId).length;
    }

    Process[] findByProject(ProjectId projectId) {
        return findAll().filter!(p => p.projectId == projectId).array;
    }
    void removeByProject(ProjectId projectId) {
        findByProject(projectId).each!(p => remove(p));
    }

    size_t countByCategory(TenantId tenantId, ProcessCategory category) {
        return findByCategory(tenantId, category).length;
    }
    Process[] findByCategory(TenantId tenantId, ProcessCategory category) {
        return findAll().filter!(p => p.tenantId == tenantId && p.category == category).array;
    }
    void removeByCategory(TenantId tenantId, ProcessCategory category) {
        findByCategory(tenantId, category).each!(p => remove(p));
    }

}
