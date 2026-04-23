/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.ports.repositories.task_actions;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface TaskActionRepository : ITenantRepository!(TaskAction, TaskActionId) {

    size_t countByTask(TaskId taskId);
    TaskAction[] findByTask(TaskId taskId);
    void removeByTask(TaskId taskId);

    size_t countByPerformer(string performedBy);
    TaskAction[] findByPerformer(string performedBy);
    void removeByPerformer(string performedBy);

}
