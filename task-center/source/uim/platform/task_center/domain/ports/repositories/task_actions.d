/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskActionRepository {
    TaskAction findById(TaskActionId id);
    TaskAction[] findByTenant(TenantId tenantId);
    TaskAction[] findByTask(TaskId taskId);
    TaskAction[] findByPerformer(string performedBy);
    void save(TaskAction entity);
    void remove(TaskActionId id);
}
