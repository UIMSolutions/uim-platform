/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_comments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskCommentRepository : TenantRepository!(TaskComment, TaskCommentId), TaskCommentRepository {
    private TaskComment[][string] store;

    TaskComment findById(string tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (c; *arr)
                if (c.id == id) return c;
        return TaskComment.init;
    }

    TaskComment[] findByTenant(string tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return null;
    }

    TaskComment[] findByTask(string tenantId, string taskId) {
        TaskComment[] result;
        if (auto arr = tenantId in store)
            foreach (c; *arr)
                if (c.taskId == taskId) result ~= c;
        return result;
    }

    void save(string tenantId, TaskComment entity) {
        store[tenantId] ~= entity;
    }

    void update(string tenantId, TaskComment entity) {
        if (auto arr = tenantId in store)
            foreach (c; *arr)
                if (c.id == entity.id) { c = entity; return; }
    }

    void remove(string tenantId, string id) {
        if (auto arr = tenantId in store) {
            TaskComment[] filtered;
            foreach (c; *arr)
                if (c.id != id) filtered ~= c;
            store[tenantId] = filtered;
        }
    }
}
