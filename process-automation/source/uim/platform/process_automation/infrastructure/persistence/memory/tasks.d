/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.tasks;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryTaskRepository : TenantRepository!(Task, TaskId), TaskRepository {

    size_t countByAssignee(TenantId tenantId, string assignee) {
        return findByAssignee(tenantId, assignee).length;
    }
    Task[] findByAssignee(TenantId tenantId, string assignee) {
        return findAll().filter!(t => t.tenantId == tenantId && t.assignee == assignee).array;
    }
    void removeByAssignee(TenantId tenantId, string assignee) {
        findByAssignee(tenantId, assignee).each!(t => remove(t.id));
    }

    size_t countByProcessInstance(ProcessInstanceId instanceId) {
        return findByProcessInstance(instanceId).length;
    }
    Task[] findByProcessInstance(ProcessInstanceId instanceId) {
        return findAll().filter!(t => t.processInstanceId == instanceId).array;
    }
    void removeByProcessInstance(ProcessInstanceId instanceId) {
        findByProcessInstance(instanceId).each!(t => remove(t.id));
    }

    size_t countByStatus(TenantId tenantId, TaskStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Task[] findByStatus(TenantId tenantId, TaskStatus status) {
        return findAll().filter!(t => t.tenantId == tenantId && t.status == status).array;
    }
    void removeByStatus(TenantId tenantId, TaskStatus status) {
        findByStatus(tenantId, status).each!(t => remove(t.id));
    }

}
