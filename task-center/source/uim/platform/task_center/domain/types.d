/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.types;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:
// --- ID Aliases ---

struct TaskId  {
    mixin(IdTemplate);
}
struct TaskDefinitionId  {
    mixin(IdTemplate);
}
struct TaskCommentId  {
    mixin(IdTemplate);
}
struct TaskAttachmentId  {
    mixin(IdTemplate);
}
struct TaskProviderId  {
    mixin(IdTemplate);
}
struct SubstitutionRuleId  {
    mixin(IdTemplate);
}
struct TaskActionId  {
    mixin(IdTemplate);
}
struct UserTaskFilterId  {
    mixin(IdTemplate);
}


