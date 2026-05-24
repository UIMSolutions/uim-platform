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

    mixin DomainId;
}
struct ProcessId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ProcessStepId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ProcessInstanceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TaskId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TaskAttachmentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TaskCommentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DecisionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DecisionRowId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct DecisionColumnId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FormId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FormFieldId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FormSectionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AutomationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AutomationStepId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct AutomationRunId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TriggerId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ActionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct VisibilityId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct VisibilityMetricId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ProjectId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct VersionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}