/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.task;

import uim.platform.process_automation.domain.types;

struct TaskComment {
    string id;
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
    TaskId id;
    ProcessInstanceId processInstanceId;
    TenantId tenantId;
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
    long createdAt;
    long dueDate;
    long completedAt;
}
