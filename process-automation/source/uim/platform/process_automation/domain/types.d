/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.types;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
// ID aliases
struct ArtifactId  {
    mixin(IdTemplate);
}
struct ProcessId  {
    mixin(IdTemplate);
}

struct ProcessStepId  {
    mixin(IdTemplate);
}
struct ProcessInstanceId  {
    mixin(IdTemplate);
}
struct TaskId  {
    mixin(IdTemplate);
}

struct TaskAttachmentId  {
    mixin(IdTemplate);
}

struct TaskCommentId  {
    mixin(IdTemplate);
}
struct DecisionId  {
    mixin(IdTemplate);
}

struct DecisionRowId  {
    mixin(IdTemplate);
}

struct DecisionColumnId  {
    mixin(IdTemplate);
}
struct FormId  {
    mixin(IdTemplate);
}
struct FormFieldId  {
    mixin(IdTemplate);
}
struct FormSectionId  {
    mixin(IdTemplate);
}
struct AutomationId  {
    mixin(IdTemplate);
}

struct AutomationStepId  {
    mixin(IdTemplate);
}

struct AutomationRunId  {
    mixin(IdTemplate);
}
struct TriggerId  {
    mixin(IdTemplate);
}
struct ActionId  {
    mixin(IdTemplate);
}
struct VisibilityId  {
    mixin(IdTemplate);
}

struct VisibilityMetricId  {
    mixin(IdTemplate);
}
struct ProjectId  {
    mixin(IdTemplate);
}
struct VersionId  {
    mixin(IdTemplate);
}