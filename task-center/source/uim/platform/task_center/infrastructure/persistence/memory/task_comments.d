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

    size_t countByTask(TenantId tenantId, string taskId) {
        return findByTask(tenantId, taskId).length;
    }
    TaskComment[] findByTask(TenantId tenantId, string taskId) {
        TaskComment[] result;
        if (auto arr = tenantId in store)
            foreach (c; *arr)
                if (c.taskId == taskId) result ~= c;
        return result;
    }
    void removeByTask(TenantId tenantId, string taskId) {
        if (auto arr = tenantId in store)
            store[tenantId] = (*arr).filter!(c => c.taskId != taskId).array;
    }
}
