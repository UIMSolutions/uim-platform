/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_comment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskComment {
    mixin TenantEntity!(TaskCommentId);

    TaskId taskId;

    string author;
    string content;

    Json toJson() const {
        return entityToJson
            .set("taskId", taskId.value)
            .set("author", author)
            .set("content", content);
    }
}
