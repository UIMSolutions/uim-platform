/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskActionRepository : TenantRepository!(TaskAction, TaskActionId), TaskActionRepository {
    private TaskAction[][string] store;

    TaskAction findById(TenantId tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (a; *arr)
                if (a.id == id) return a;
        return TaskAction.init;
    }

    TaskAction[] findByTenant(TenantId tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return null;
    }

    TaskAction[] findByTask(TenantId tenantId, string taskId) {
        TaskAction[] result;
        if (auto arr = tenantId in store)
            foreach (a; *arr)
                if (a.taskId == taskId) result ~= a;
        return result;
    }

    TaskAction[] findByPerformer(TenantId tenantId, string performerId) {
        TaskAction[] result;
        if (auto arr = tenantId in store)
            foreach (a; *arr)
                if (a.performedBy == performerId) result ~= a;
        return result;
    }

    void save(TenantId tenantId, TaskAction entity) {
        store[tenantId] ~= entity;
    }

    void remove(TenantId tenantId, string id) {
        if (auto arr = tenantId in store) {
            TaskAction[] filtered;
            foreach (a; *arr)
                if (a.id != id) filtered ~= a;
            store[tenantId] = filtered;
        }
    }
}
