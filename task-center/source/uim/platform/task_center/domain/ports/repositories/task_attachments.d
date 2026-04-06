/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_attachments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskAttachmentRepository {
    TaskAttachment findById(TaskAttachmentId id);
    TaskAttachment[] findByTenant(TenantId tenantId);
    TaskAttachment[] findByTask(TaskId taskId);
    void save(TaskAttachment entity);
    void remove(TaskAttachmentId id);
}
