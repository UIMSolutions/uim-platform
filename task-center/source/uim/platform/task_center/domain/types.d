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

alias TaskId = string;
alias TaskDefinitionId = string;
alias TaskCommentId = string;
alias TaskAttachmentId = string;
alias TaskProviderId = string;
alias SubstitutionRuleId = string;
alias TaskActionId = string;
alias UserTaskFilterId = string;
alias TenantId = string;
alias UserId = string;

// --- Enums ---

enum TaskStatus {
    open,
    inProgress,
    completed,
    cancelled,
    failed,
    forwarded,
    reserved
}

enum TaskPriority {
    low,
    medium,
    high,
    veryHigh
}

enum TaskCategory {
    approval,
    review,
    toDoItem,
    notification,
    action,
    workflow,
    informational
}

enum ProviderType {
    s4hana,
    successFactors,
    ariba,
    fieldglass,
    concur,
    sapBuild,
    custom
}

enum ProviderStatus {
    active,
    inactive,
    error,
    syncing
}

enum AuthenticationType {
    oauth2,
    basicAuth,
    certificate,
    apiKey,
    saml
}

enum ActionType {
    approve,
    reject,
    forward,
    claim,
    release,
    escalate,
    complete,
    cancel,
    resubmit
}

enum SubstitutionStatus {
    active,
    inactive,
    expired,
    pending
}

enum AttachmentStatus {
    uploaded,
    processing,
    available,
    deleted
}

enum FilterCriterionType {
    status,
    priority,
    provider,
    category,
    dueDate,
    assignee,
    creator,
    taskDefinition
}
