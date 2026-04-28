/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.dto;

import uim.platform.process_automation.domain.types;





// --- Process (Workflow Definition) ---

struct CreateProcessRequest {
    TenantId tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string category;
    string version_;
    UserId createdBy;
}

struct UpdateProcessRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    string version_;
    UserId modifiedBy;
}

struct DeployProcessRequest {
    TenantId tenantId;
    string id;
    string action;
}

// --- Process Instance ---

struct StartProcessInstanceRequest {
    TenantId tenantId;
    string processId;
    string id;
    string startedBy;
    string priority;
    string[][] context;
    long dueDate;
}

struct UpdateProcessInstanceRequest {
    TenantId tenantId;
    string id;
    string status;
    string currentStepId;
}

struct ProcessInstanceActionRequest {
    TenantId tenantId;
    string id;
    string action;
}

// --- Task ---

struct CreateTaskRequest {
    TenantId tenantId;
    string processInstanceId;
    string id;
    string name;
    string description;
    string type;
    string priority;
    string assignee;
    string[] candidateUsers;
    string[] candidateGroups;
    string formId;
    long dueDate;
}

struct UpdateTaskRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string priority;
    string assignee;
    long dueDate;
}

struct CompleteTaskRequest {
    TenantId tenantId;
    string id;
    string completedBy;
    string outcome;
    string formData;
}

struct ClaimTaskRequest {
    TenantId tenantId;
    string id;
    string userId;
}

// --- Decision ---

struct CreateDecisionRequest {
    TenantId tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string type;
    string hitPolicy;
    string version_;
    UserId createdBy;
}

struct UpdateDecisionRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string hitPolicy;
    string version_;
    UserId modifiedBy;
}

// --- Form ---

struct CreateFormRequest {
    TenantId tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string version_;
    UserId createdBy;
}

struct UpdateFormRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string version_;
    UserId modifiedBy;
}

// --- Automation (RPA Bot) ---

struct CreateAutomationRequest {
    TenantId tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    UserId createdBy;
}

struct UpdateAutomationRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    UserId modifiedBy;
}

struct RunAutomationRequest {
    TenantId tenantId;
    string id;
    string triggeredBy;
    string inputData;
}

// --- Trigger ---

struct CreateTriggerRequest {
    TenantId tenantId;
    string processId;
    string id;
    string name;
    string description;
    string type;
    string cronExpression;
    string eventType;
    string eventSource;
    string filterExpression;
    UserId createdBy;
}

struct UpdateTriggerRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string cronExpression;
    string eventType;
    string filterExpression;
}

// --- Action (Integration) ---

struct CreateActionRequest {
    TenantId tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string type;
    string method;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string version_;
    UserId createdBy;
}

struct UpdateActionRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string version_;
    UserId modifiedBy;
}

// --- Visibility (Process Monitoring) ---

struct CreateVisibilityRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string dashboardType;
    string[] processIds;
    string refreshIntervalSeconds;
    UserId createdBy;
}

struct UpdateVisibilityRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string refreshIntervalSeconds;
    UserId modifiedBy;
}

// --- Artifact Store ---

struct CreateArtifactRequest {
    string id;
    string name;
    string description;
    string type;
    string version_;
    string author;
    string category;
    string[] tags;
    string contentUrl;
}

struct UpdateArtifactRequest {
    string id;
    string name;
    string description;
    string version_;
    string contentUrl;
}

struct InstallArtifactRequest {
    TenantId tenantId;
    string artifactId;
}
