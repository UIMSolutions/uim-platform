/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct Task {
    TaskId id;
    TenantId tenantId;
    TaskDefinitionId taskDefinitionId;
    TaskProviderId providerId;
    string externalTaskId;

    string title;
    string description;
    TaskStatus status = TaskStatus.open;
    TaskPriority priority = TaskPriority.medium;
    TaskCategory category = TaskCategory.approval;

    string assignee;
    string creator;
    string processor;
    string sourceApplication;

    string[] allowedActions;
    string[string] customAttributes;

    bool isClaimed;
    string claimedBy;

    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
    string dueDate;
    string completedAt;
}
