/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.infrastructure.persistence.memory.task_attachments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class MemoryTaskAttachmentRepository :TenantRepository!(TaskAttachment, TaskAttachmentId), TaskAttachmentRepository {
    private TaskAttachment[][string] store;

    TaskAttachment findById(string tenantId, string id) {
        if (auto arr = tenantId in store)
            foreach (a; *arr)
                if (a.id == id) return a;
        return TaskAttachment.init;
    }

    TaskAttachment[] findByTenant(string tenantId) {
        if (auto arr = tenantId in store) return *arr;
        return [];
    }

    TaskAttachment[] findByTask(string tenantId, string taskId) {
        TaskAttachment[] result;
        if (auto arr = tenantId in store)
            foreach (a; *arr)
                if (a.taskId == taskId) result ~= a;
        return result;
    }

    void save(string tenantId, TaskAttachment entity) {
        store[tenantId] ~= entity;
    }

    void remove(string tenantId, string id) {
        if (auto arr = tenantId in store) {
            TaskAttachment[] filtered;
            foreach (a; *arr)
                if (a.id != id) filtered ~= a;
            store[tenantId] = filtered;
        }
    }
}
