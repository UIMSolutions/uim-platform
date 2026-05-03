/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.process_instances;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryProcessInstanceRepository : TenantRepository!(ProcessInstance, ProcessInstanceId), ProcessInstanceRepository {

    size_t countByProcess(ProcessId processId) {
        return findByProcess(processId).length;
    }
    ProcessInstance[] findByProcess(ProcessId processId) {
        return findAll().filter!(i => i.processId == processId).array;
    }
    void removeByProcess(ProcessId processId) {
        findByProcess(processId).each!(i => remove(i.id));
    }

    size_t countByStatus(TenantId tenantId, InstanceStatus status) {
        return findByStatus(tenantId, status).length;
    }
    ProcessInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return findAll().filter!(i => i.tenantId == tenantId && i.status == status).array;
    }
    void removeByStatus(TenantId tenantId, InstanceStatus status) {
        findByStatus(tenantId, status).each!(i => remove(i.id));
    }

}
