/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

struct UIMTask {
    mixin TenantEntity!TaskId;

    TaskDefinitionId definitionId;
    TaskProviderId providerId;
    TaskId externalTaskId;

    string title;
    string description;
    TaskStatus status = TaskStatus.open;
    TaskPriority priority = TaskPriority.medium;
    TaskCategory category = TaskCategory.approval;

    UserId assignee;
    string creator;
    string processor;
    string sourceApplication;

    string[] allowedActions;
    string[string] customAttributes;

    bool isClaimed;
    UserId claimedBy;

    string dueDate;
    long completedAt;

    Json toJson() const {
        return entityToJson
            .set("taskDefinitionId", definitionId.value)
            .set("providerId", providerId.value)
            .set("externalTaskId", externalTaskId.value)
            .set("title", title)
            .set("description", description)
            .set("status", status.to!string)
            .set("priority", priority.to!string)
            .set("category", category.to!string)
            .set("assignee", assignee)
            .set("creator", creator)
            .set("processor", processor)
            .set("sourceApplication", sourceApplication)
            .set("allowedActions", allowedActions.array.toJson)
            .set("customAttributes", customAttributes)
            .set("isClaimed", isClaimed)
            .set("claimedBy", claimedBy)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt);
    }
}
