/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.types;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:
// --- ID Aliases ---

struct TaskId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskDefinitionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskCommentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskAttachmentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskProviderId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct SubstitutionRuleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskActionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct UserTaskFilterId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}


