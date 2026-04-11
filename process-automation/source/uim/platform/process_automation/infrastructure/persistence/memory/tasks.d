/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.tasks;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryTaskRepository : TaskRepository {
    private Task[] store;

    Task findById(TaskId id) {
        foreach (t; store) {
            if (t.id == id)
                return t;
        }
        return Task.init;
    }

    Task[] findByTenant(TenantId tenantId) {
        return store.filter!(t => t.tenantId == tenantId).array;
    }

    Task[] findByAssignee(TenantId tenantId, string assignee) {
        return store.filter!(t => t.tenantId == tenantId && t.assignee == assignee).array;
    }

    Task[] findByProcessInstance(ProcessInstanceId instanceId) {
        return store.filter!(t => t.processInstanceId == instanceId).array;
    }

    Task[] findByStatus(TenantId tenantId, TaskStatus status) {
        return store.filter!(t => t.tenantId == tenantId && t.status == status).array;
    }

    void save(Task t) {
        store ~= t;
    }

    void update(Task t) {
        foreach (existing; store) {
            if (existing.id == t.id) {
                existing = t;
                return;
            }
        }
    }

    void remove(TaskId id) {
        store = store.filter!(t => t.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return store.filter!(t => t.tenantId == tenantId).array.length;
    }
}
