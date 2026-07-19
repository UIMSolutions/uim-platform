/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task;

import uim.platform.task_center;
mixin(ShowModule!());

@safe:

struct UIMTask {
    mixin TenantEntity!TaskId;

    TaskDefinitionId definitionId; // reference to the task definition that defines the template and rules for this task
    TaskProviderId providerId; // reference to the provider that created this task, used for tracking the source and syncing updates
    TaskId externalTaskId; // the ID of the task in the external system (e.g., Jira issue ID, GitHub issue number), used for syncing updates and avoiding duplicates

    string title; // a brief title for the task, e.g., "Review PR #123", "Approve Expense Report"
    string description; // a detailed description of the task, which can include markdown formatting and links to relevant resources (e.g., "Please review the changes in PR #123:
    TaskStatus status = TaskStatus.open; // open, in_progress, completed, cancelled
    TaskPriority priority = TaskPriority.medium; // low, medium, high
    TaskCategory category = TaskCategory.approval; // approval, review, action, etc. - can be used for filtering and routing tasks

    string assignee; // the user to whom the task is currently assigned, can be empty if unassigned. This is a string to allow for flexibility in representing users from different systems (e.g., "user 
    string creator; // could be a user or system, so keeping it as string for flexibility
    string processor; // could be a user or system responsible for processing the task, separate from assignee for cases like auto-processing
    string sourceApplication; // the application from which the task originated (e.g., "Jira", "GitHub", "Custom API")

    string[] allowedActions; // list of actions that can be performed on this task (e.g., "claim", "complete", "reassign"), used for driving the UI and enforcing rules
    string[string] customAttributes; // a flexible map for any additional attributes that may be needed for specific task types or providers, allowing for extensibility without changing the core schema

    bool isClaimed; // indicates whether the task has been claimed by a user, used for managing task assignment and visibility in the UI
    UserId claimedBy; // the user who has claimed the task, if any, used for tracking and enforcing rules around claiming and processing tasks

    string dueDate; // the due date of the task, used for tracking and reporting
    long completedAt; // timestamp of when the task was completed, used for tracking and reporting

    Json toJson() const {
        auto attributes = Json.emptyObject; 
        foreach (k, v; customAttributes) {
            attributes[k] = v;
        }

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
            .set("customAttributes", attributes)
            .set("isClaimed", isClaimed)
            .set("claimedBy", claimedBy)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt);
    }
}
