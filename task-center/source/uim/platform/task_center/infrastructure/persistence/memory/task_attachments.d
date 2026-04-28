/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_attachments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskAttachmentRepository : TenantRepository!(TaskAttachment, TaskAttachmentId), TaskAttachmentRepository {

    size_t countByTask(TenantId tenantId, TaskId taskId) {
        return findByTask(tenantId, taskId).length;
    }
    TaskAttachment[] filterByTask(TaskAttachment[] attachments, TaskId taskId) {
        return attachments.filter!(a => a.taskId == taskId).array;
    }
    TaskAttachment[] findByTask(TenantId tenantId, TaskId taskId) {
        return filterByTask(findByTenant(tenantId), taskId);
    }
    void removeByTask(TenantId tenantId, TaskId taskId) {
        findByTask(tenantId, taskId).each!(a => remove(a));
    }

}
