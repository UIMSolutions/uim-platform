/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.processes;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class MemoryProcessRepository : TentRepository!(Process, ProcessId), ProcessRepository {
    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }

    Process[] findByProject(TenantId tenantId, ProjectId projectId) {
        return filterByProject(findByTenant(tenantId), projectId);
    }
    Process[] filterByProject(Process[] processes, ProjectId projectId) {
        return processes.filter!(p => p.projectId == projectId).array;
    }
    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(p => remove(p));
    }

    size_t countByCategory(TenantId tenantId, ProcessCategory category) {
        return findByCategory(tenantId, category).length;
    }
    Process[] findByCategory(TenantId tenantId, ProcessCategory category) {
        return filterByCategory(findByTenant(tenantId), category);
    }
    Process[] filterByCategory(Process[] processes, ProcessCategory category) {
        return processes.filter!(p => p.category == category).array;
    }
    void removeByCategory(TenantId tenantId, ProcessCategory category) {
        findByCategory(tenantId, category).each!(p => remove(p));
    }

}
