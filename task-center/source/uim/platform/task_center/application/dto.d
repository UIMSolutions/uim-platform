/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dto;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Task DTOs ---

struct CreateTaskRequest {
    string tenantId;
    string id;
    string taskDefinitionId;
    string providerId;
    string externalTaskId;
    string title;
    string description;
    string priority;
    string category;
    string assignee;
    string creator;
    string sourceApplication;
    string dueDate;
    string createdBy;
}

struct UpdateTaskRequest {
    string tenantId;
    string id;
    string title;
    string description;
    string priority;
    string assignee;
    string dueDate;
    string modifiedBy;
}

// --- Task Definition DTOs ---

struct CreateTaskDefinitionRequest {
    string tenantId;
    string id;
    string providerId;
    string name;
    string description;
    string category;
    string taskSchema;
    bool requiresClaim;
    string createdBy;
}

struct UpdateTaskDefinitionRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string taskSchema;
    bool requiresClaim;
    string modifiedBy;
}

// --- Task Comment DTOs ---

struct CreateTaskCommentRequest {
    string tenantId;
    string id;
    string taskId;
    string author;
    string content;
}

struct UpdateTaskCommentRequest {
    string tenantId;
    string id;
    string content;
}

// --- Task Attachment DTOs ---

struct CreateTaskAttachmentRequest {
    string tenantId;
    string id;
    string taskId;
    string fileName;
    string fileSize;
    string mimeType;
    string uploadedBy;
}

// --- Task Provider DTOs ---

struct CreateTaskProviderRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string providerType;
    string authType;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    string createdBy;
}

struct UpdateTaskProviderRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string endpointUrl;
    string authEndpointUrl;
    string clientId;
    string modifiedBy;
}

// --- Substitution Rule DTOs ---

struct CreateSubstitutionRuleRequest {
    string tenantId;
    string id;
    string userId;
    string substituteId;
    string taskDefinitionId;
    string startDate;
    string endDate;
    bool isAutoForward;
    string createdBy;
}

struct UpdateSubstitutionRuleRequest {
    string tenantId;
    string id;
    string substituteId;
    string taskDefinitionId;
    string startDate;
    string endDate;
    bool isAutoForward;
    string modifiedBy;
}

// --- Task Action DTOs ---

struct PerformTaskActionRequest {
    string tenantId;
    string id;
    string taskId;
    string actionType;
    string performedBy;
    string forwardTo;
    string comment;
}

// --- User Task Filter DTOs ---

struct CreateUserTaskFilterRequest {
    string tenantId;
    string id;
    string userId;
    string name;
    string description;
    bool isDefault;
}

struct UpdateUserTaskFilterRequest {
    string tenantId;
    string id;
    string name;
    string description;
    bool isDefault;
}
