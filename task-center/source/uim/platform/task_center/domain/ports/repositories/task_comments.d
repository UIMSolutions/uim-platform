/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_comments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskCommentRepository {
    TaskComment findById(TaskCommentId id);
    TaskComment[] findByTenant(TenantId tenantId);
    TaskComment[] findByTask(TaskId taskId);
    void save(TaskComment entity);
    void update(TaskComment entity);
    void remove(TaskCommentId id);
}
