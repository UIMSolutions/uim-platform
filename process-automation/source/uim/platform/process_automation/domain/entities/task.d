/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.task;

import uim.platform.process_automation.domain.types;

struct TaskComment {
    TaskCommentId id;
    string userId;
    string text;
    long createdAt;
}

struct TaskAttachment {
    string id;
    string name;
    string contentType;
    long sizeBytes;
    string url;
    long uploadedAt;
}

struct Task {
    mixin TenantEntity!(TaskId);

    ProcessInstanceId processInstanceId;
    string name;
    string description;
    TaskType type;
    TaskStatus status;
    TaskPriority priority;
    string assignee;
    string[] candidateUsers;
    string[] candidateGroups;
    string formId;
    string formData;
    TaskComment[] comments;
    TaskAttachment[] attachments;
    string completedBy;
    string outcome;
    long dueDate;
    long completedAt;

    Json toJson() const {
        return entityToJson
            .set("processInstanceId", processInstanceId.value)
            .set("name", name)
            .set("description", description)
            .set("type", type.toString())
            .set("status", status.toString())
            .set("priority", priority.toString())
            .set("assignee", assignee)
            .set("candidateUsers", candidateUsers.array)
            .set("candidateGroups", candidateGroups.array)
            .set("formId", formId)
            .set("formData", formData)
            .set("comments", comments.map!(c => c.toJson()).array)
            .set("attachments", attachments.map!(a => a.toJson()).array)
            .set("completedBy", completedBy)
            .set("outcome", outcome)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt);
    }
}
