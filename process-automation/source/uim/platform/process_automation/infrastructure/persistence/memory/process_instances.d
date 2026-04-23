/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.process_instances;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryProcessInstanceRepository : ProcessInstanceRepository {
    private ProcessInstance[] store;

    ProcessInstance findById(ProcessInstanceId id) {
        foreach (i; store) {
            if (i.id == id)
                return i;
        }
        return ProcessInstance.init;
    }

    ProcessInstance[] findByTenant(TenantId tenantId) {
        return findAll().filter!(i => i.tenantId == tenantId).array;
    }

    ProcessInstance[] findByProcess(ProcessId processId) {
        return findAll().filter!(i => i.processId == processId).array;
    }

    ProcessInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return findAll().filter!(i => i.tenantId == tenantId && i.status == status).array;
    }

    void save(ProcessInstance i) {
        store ~= i;
    }

    void update(ProcessInstance i) {
        foreach (existing; store) {
            if (existing.id == i.id) {
                existing = i;
                return;
            }
        }
    }

    void remove(ProcessInstanceId id) {
        store = findAll().filter!(i => i.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return findAll().filter!(i => i.tenantId == tenantId).array.length;
    }
}
