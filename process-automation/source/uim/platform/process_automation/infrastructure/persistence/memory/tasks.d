/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.tasks;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class MemoryTaskRepository : TenantRepository!(PATask, TaskId), TaskRepository {

    size_t countByAssignee(TenantId tenantId, UserId assignee) {
        return findByAssignee(tenantId, assignee).length;
    }

    PATask[] findByAssignee(TenantId tenantId, UserId assignee) {
        return filterByAssignee(findByTenant(tenantId), assignee);
    }
    PATask[] filterByAssignee(PATask[] tasks, UserId assignee) {
        return tasks.filter!(t => t.assignee == assignee).array;
    }
    void removeByAssignee(TenantId tenantId, UserId assignee) {
        findByAssignee(tenantId, assignee).each!(t => remove(t));
    }

    size_t countByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId) {
        return findByProcessInstance(tenantId, instanceId).length;
    }
    PATask[] findByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId) {
        return filterByProcessInstance(findByTenant(tenantId), instanceId);
    }
    PATask[] filterByProcessInstance(PATask[] tasks, ProcessInstanceId instanceId) {
        return tasks.filter!(t => t.processInstanceId == instanceId).array;
    }
    void removeByProcessInstance(TenantId tenantId, ProcessInstanceId instanceId) {
        findByProcessInstance(tenantId, instanceId).each!(t => remove(t));
    }

    size_t countByStatus(TenantId tenantId, TaskStatus status) {
        return findByStatus(tenantId, status).length;
    }
    PATask[] findByStatus(TenantId tenantId, TaskStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    PATask[] filterByStatus(PATask[] tasks, TaskStatus status) {
        return tasks.filter!(t => t.status == status).array;
    }
    void removeByStatus(TenantId tenantId, TaskStatus status) {
        findByStatus(tenantId, status).each!(t => remove(t));
    }

}
