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
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ProcessId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ProcessStepId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ProcessInstanceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TaskId  {
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

struct TaskCommentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct DecisionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DecisionRowId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DecisionColumnId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct FormId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct FormFieldId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct FormSectionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct AutomationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct AutomationStepId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct AutomationRunId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct TriggerId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ActionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct VisibilityId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct VisibilityMetricId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct ProjectId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
struct VersionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}