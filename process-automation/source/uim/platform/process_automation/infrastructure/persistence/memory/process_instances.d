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

    size_t countByProcess(TenantId tenantId, ProcessId processId) {
        return findByProcess(tenantId, processId).length;
    }
    ProcessInstance[] findByProcess(TenantId tenantId, ProcessId processId) {
        return filterByProcess(findByTenant(tenantId), processId);
    }
    ProcessInstance[] filterByProcess(ProcessInstance[] instances, ProcessId processId) {
        return instances.filter!(i => i.processId == processId).array;
    }
    void removeByProcess(TenantId tenantId, ProcessId processId) {
        findByProcess(tenantId, processId).each!(i => remove(i.id));
    }

    size_t countByStatus(TenantId tenantId, InstanceStatus status) {
        return findByStatus(tenantId, status).length;
    }
    ProcessInstance[] filterByStatus(ProcessInstance[] instances, InstanceStatus status) {
        return instances.filter!(i => i.status == status).array;
    }   
    ProcessInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, InstanceStatus status) {
        findByStatus(tenantId, status).each!(i => remove(i.id));
    }

}
