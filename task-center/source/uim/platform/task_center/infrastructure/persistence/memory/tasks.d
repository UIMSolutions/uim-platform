/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskRepository : TenantRepository!(Task, TaskId), TaskRepository {
    private Task[][string] store;

    Task findById(TenantId tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.id == id) return t;
        return Task.init;
    }

    Task[] findByTenant(TenantId tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return null;
    }

    Task[] findByAssignee(TenantId tenantId, string assignee) {
        Task[] result;
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.assignee == assignee) result ~= t;
        return result;
    }

    Task[] findByStatus(TenantId tenantId, TaskStatus status) {
        Task[] result;
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.status == status) result ~= t;
        return result;
    }

    Task[] findByProvider(TenantId tenantId, string providerId) {
        Task[] result;
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.providerId == providerId) result ~= t;
        return result;
    }

    Task[] findByCategory(TenantId tenantId, TaskCategory category) {
        Task[] result;
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.category == category) result ~= t;
        return result;
    }

    Task[] findByPriority(TenantId tenantId, TaskPriority priority) {
        Task[] result;
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.priority == priority) result ~= t;
        return result;
    }

    void save(TenantId tenantId, Task entity) {
        store[tenantId] ~= entity;
    }

    void update(TenantId tenantId, Task entity) {
        if (auto arr = tenantId in store)
            foreach (t; *arr)
                if (t.id == entity.id) { t = entity; return; }
    }

    void remove(TenantId tenantId, string id) {
        if (auto arr = tenantId in store) {
            Task[] filtered;
            foreach (t; *arr)
                if (t.id != id) filtered ~= t;
            store[tenantId] = filtered;
        }
    }
}
