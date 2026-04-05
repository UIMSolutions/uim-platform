/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.dto;

import uim.platform.process_automation.domain.types;

// --- Generic result ---

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Process (Workflow Definition) ---

struct CreateProcessRequest {
    string tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string category;
    string version_;
    string createdBy;
}

struct UpdateProcessRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string version_;
    string modifiedBy;
}

struct DeployProcessRequest {
    string tenantId;
    string id;
    string action;
}

// --- Process Instance ---

struct StartProcessInstanceRequest {
    string tenantId;
    string processId;
    string id;
    string startedBy;
    string priority;
    string[][] context;
    long dueDate;
}

struct UpdateProcessInstanceRequest {
    string tenantId;
    string id;
    string status;
    string currentStepId;
}

struct ProcessInstanceActionRequest {
    string tenantId;
    string id;
    string action;
}

// --- Task ---

struct CreateTaskRequest {
    string tenantId;
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
    string tenantId;
    string id;
    string name;
    string description;
    string priority;
    string assignee;
    long dueDate;
}

struct CompleteTaskRequest {
    string tenantId;
    string id;
    string completedBy;
    string outcome;
    string formData;
}

struct ClaimTaskRequest {
    string tenantId;
    string id;
    string userId;
}

// --- Decision ---

struct CreateDecisionRequest {
    string tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string type;
    string hitPolicy;
    string version_;
    string createdBy;
}

struct UpdateDecisionRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string hitPolicy;
    string version_;
    string modifiedBy;
}

// --- Form ---

struct CreateFormRequest {
    string tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string version_;
    string createdBy;
}

struct UpdateFormRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string version_;
    string modifiedBy;
}

// --- Automation (RPA Bot) ---

struct CreateAutomationRequest {
    string tenantId;
    string projectId;
    string id;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    string createdBy;
}

struct UpdateAutomationRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    string modifiedBy;
}

struct RunAutomationRequest {
    string tenantId;
    string id;
    string triggeredBy;
    string inputData;
}

// --- Trigger ---

struct CreateTriggerRequest {
    string tenantId;
    string processId;
    string id;
    string name;
    string description;
    string type;
    string cronExpression;
    string eventType;
    string eventSource;
    string filterExpression;
    string createdBy;
}

struct UpdateTriggerRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string cronExpression;
    string eventType;
    string filterExpression;
}

// --- Action (Integration) ---

struct CreateActionRequest {
    string tenantId;
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
    string createdBy;
}

struct UpdateActionRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string version_;
    string modifiedBy;
}

// --- Visibility (Process Monitoring) ---

struct CreateVisibilityRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string dashboardType;
    string[] processIds;
    string refreshIntervalSeconds;
    string createdBy;
}

struct UpdateVisibilityRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string refreshIntervalSeconds;
    string modifiedBy;
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
    string tenantId;
    string artifactId;
}
