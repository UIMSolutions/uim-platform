/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_actions;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

interface TaskActionRepository : ITentRepository!(TaskAction, TaskActionId) {

    size_t countByTask(TenantId tenantId, TaskId taskId);
    TaskAction[] findByTask(TenantId tenantId, TaskId taskId);
    void removeByTask(TenantId tenantId, TaskId taskId);

    size_t countByPerformer(TenantId tenantId, UserId performedBy);
    TaskAction[] findByPerformer(TenantId tenantId, UserId performedBy);
    void removeByPerformer(TenantId tenantId, UserId performedBy);

}
