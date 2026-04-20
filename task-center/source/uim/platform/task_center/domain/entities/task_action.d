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
    mixin TenantEntity!(TaskActionId);

    TaskId taskId;

    ActionType actionType = ActionType.approve;
    string performedBy;
    string forwardTo;
    string comment;

    string performedAt;

    Json toJson() const {
        return Json.enityToJson(this)
            .set("taskId", taskId.value)
            .set("actionType", actionType)
            .set("performedBy", performedBy)
            .set("forwardTo", forwardTo)
            .set("comment", comment)
            .set("performedAt", performedAt);
    }
}
