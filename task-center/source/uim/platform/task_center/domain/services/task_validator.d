/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.services.task_validator;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskValidator {
    static bool validate(string id, string title) {
        return id.length > 0 && title.length > 0;
    }

    static bool validateAssignee(string assignee) {
        return assignee.length > 0;
    }

    static bool validateDueDate(string dueDate) {
        return dueDate.length >= 10;
    }
}
