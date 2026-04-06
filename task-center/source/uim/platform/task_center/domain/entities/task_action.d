/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskAction {
    TaskActionId id;
    TenantId tenantId;
    TaskId taskId;

    ActionType actionType = ActionType.approve;
    string performedBy;
    string forwardTo;
    string comment;

    string performedAt;
}
