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
    mixin TenantEntity!(TaskId);

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

    string dueDate;
    string completedAt;

    Json toJson() const {
        return entityToJson
            .set("taskDefinitionId", taskDefinitionId.value)
            .set("providerId", providerId.value)
            .set("externalTaskId", externalTaskId)
            .set("title", title)
            .set("description", description)
            .set("status", status.toString)
            .set("priority", priority.toString)
            .set("category", category.toString)
            .set("assignee", assignee)
            .set("creator", creator)
            .set("processor", processor)
            .set("sourceApplication", sourceApplication)
            .set("allowedActions", allowedActions.array)
            .set("customAttributes", customAttributes)
            .set("isClaimed", isClaimed)
            .set("claimedBy", claimedBy)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt);
    }
}
