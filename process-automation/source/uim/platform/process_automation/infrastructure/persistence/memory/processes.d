/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.processes;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryProcessRepository : ProcessRepository {
    private Process[] store;

    Process findById(ProcessId id) {
        foreach (p; store) {
            if (p.id == id)
                return p;
        }
        return Process.init;
    }

    Process[] findByTenant(TenantId tenantId) {
        return store.filter!(p => p.tenantId == tenantId).array;
    }

    Process[] findByProject(ProjectId projectId) {
        return store.filter!(p => p.projectId == projectId).array;
    }

    Process[] findByCategory(TenantId tenantId, ProcessCategory category) {
        return store.filter!(p => p.tenantId == tenantId && p.category == category).array;
    }

    void save(Process p) {
        store ~= p;
    }

    void update(Process p) {
        foreach (existing; store) {
            if (existing.id == p.id) {
                existing = p;
                return;
            }
        }
    }

    void remove(ProcessId id) {
        store = store.filter!(p => p.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(p => p.tenantId == tenantId).array.length;
    }
}
