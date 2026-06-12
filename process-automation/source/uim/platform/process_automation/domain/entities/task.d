/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.task;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

struct TaskComment {
    TaskCommentId id;
    UserId userId;
    string text;
    long createdAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id.value)
            .set("userId", userId.value)
            .set("text", text)
            .set("createdAt", createdAt);
    }
}

struct TaskAttachment {
    TaskAttachmentId id;
    string name;
    string contentType;
    long sizeBytes;
    string url;
    long uploadedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id.value)
            .set("name", name)
            .set("contentType", contentType)
            .set("sizeBytes", sizeBytes)
            .set("url", url)
            .set("uploadedAt", uploadedAt);
    }
}

struct PATask {
    mixin TenantEntity!(TaskId);

    ProcessInstanceId processInstanceId;
    string name;
    string description;
    TaskType type;
    TaskStatus status;
    TaskPriority priority;
    string assignee;
    UserId[] candidateUsers;
    string[] candidateGroups;
    FormId formId;
    string formData;
    TaskComment[] comments;
    TaskAttachment[] attachments;
    UserId completedBy;
    string outcome;
    string dueDate;
    long completedAt;

    Json toJson() const {
        return entityToJson
            .set("processInstanceId", processInstanceId.value)
            .set("name", name)
            .set("description", description)
            .set("type", type.to!string())
            .set("status", status.to!string())
            .set("priority", priority.to!string())
            .set("assignee", assignee)
            .set("candidateUsers", candidateUsers.map!(u => u.value).array.toJson)
            .set("candidateGroups", candidateGroups.toJson)
            .set("formId", formId)
            .set("formData", formData)
            .set("comments", comments.map!(c => c.toJson()).array.toJson)
            .set("attachments", attachments.map!(a => a.toJson()).array.toJson)
            .set("completedBy", completedBy.value)
            .set("outcome", outcome)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt);
    }
}
