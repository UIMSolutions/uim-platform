/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.dto;

import uim.platform.process_automation.domain.types;import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

// --- Process (Workflow Definition) ---

struct CreateProcessRequest {
    TenantId tenantId;
    ProjectId projectId;
    ProcessId processId;
    string name;
    string description;
    string category;
    string version_;
    UserId createdBy;
}

struct UpdateProcessRequest {
    TenantId tenantId;
    ProcessId processId;
    string name;
    string description;
    string category;
    string version_;
    UserId updatedBy;
}

struct DeployProcessRequest {
    TenantId tenantId;
    ProcessId processId;
    string action;
}
// --- Process Instance ---

struct StartProcessInstanceRequest {
    TenantId tenantId;
    ProcessId processId;
    ProcessInstanceId processInstanceId;
    UserId startedBy;
    string priority;
    string[][] context;
    string dueDate;
}

struct UpdateProcessInstanceRequest {
    TenantId tenantId;
    ProcessInstanceId processInstanceId;
    string status;
    string currentStepId;
}

struct ProcessInstanceActionRequest {
    TenantId tenantId;
    ProcessInstanceId processInstanceId;
    string action;
}
// --- PATask ---

struct CreateTaskRequest {
    TenantId tenantId;
    ProcessInstanceId processInstanceId;
    TaskId taskId;
    string name;
    string description;
    string type;
    string priority;
    string assignee;
    string[] candidateUsers;
    string[] candidateGroups;
    string formId;
    string dueDate;
}

struct UpdateTaskRequest {
    TenantId tenantId;
    TaskId taskId;
    string name;
    string description;
    string priority;
    string assignee;
    string dueDate;
}

struct CompleteTaskRequest {
    TenantId tenantId;
    TaskId taskId;
    UserId completedBy;
    string outcome;
    string formData;
}

struct ClaimTaskRequest {
    TenantId tenantId;
    TaskId taskId;
    UserId userId;
}
// --- Decision ---

struct CreateDecisionRequest {
    TenantId tenantId;
    ProjectId projectId;
    DecisionId decisionId;
    string name;
    string description;
    string type;
    string hitPolicy;
    string version_;
    UserId createdBy;
}

struct UpdateDecisionRequest {
    TenantId tenantId;
    DecisionId decisionId;
    string name;
    string description;
    string hitPolicy;
    string version_;
    UserId updatedBy;
}
// --- Form ---

struct CreateFormRequest {
    TenantId tenantId;
    ProjectId projectId;
    FormId formId;
    string name;
    string description;
    string version_;
    UserId createdBy;
}

struct UpdateFormRequest {
    TenantId tenantId;
    FormId formId;
    string name;
    string description;
    string version_;
    UserId updatedBy;
}
// --- Automation (RPA Bot) ---

struct CreateAutomationRequest {
    TenantId tenantId;
    ProjectId projectId;
    AutomationId automationId;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    UserId createdBy;
}

struct UpdateAutomationRequest {
    TenantId tenantId;
    AutomationId automationId;
    string name;
    string description;
    string type;
    string targetApplication;
    string version_;
    UserId updatedBy;
}

struct RunAutomationRequest {
    TenantId tenantId;
    AutomationId automationId;
    UserId triggeredBy;
    string inputData;
}
// --- Trigger ---

struct CreateTriggerRequest {
    TenantId tenantId;
    ProcessId processId;
    TriggerId triggerId;
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
    TriggerId triggerId;
    string name;
    string description;
    string cronExpression;
    string eventType;
    string filterExpression;
}
// --- Action (Integration) ---

struct CreateActionRequest {
    TenantId tenantId;
    ProjectId projectId;
    ActionId actionId;
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
    ActionId actionId;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string version_;
    UserId updatedBy;
}
// --- Visibility (Process Monitoring) ---

struct CreateVisibilityRequest {
    TenantId tenantId;
    VisibilityId visibilityId;
    string name;
    string description;
    string dashboardType;
    string[] processIds;
    string refreshIntervalSeconds;
    UserId createdBy;
}

struct UpdateVisibilityRequest {
    TenantId tenantId;
    VisibilityId visibilityId;
    string name;
    string description;
    string refreshIntervalSeconds;
    UserId updatedBy;
}
// --- Artifact Store ---

struct CreateArtifactRequest {
    ArtifactId artifactId;
    TenantId tenantId;
    UserId createdBy;
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
    ArtifactId artifactId;
    TenantId tenantId;
    UserId updatedBy;   
    string name;
    string description;
    string version_;
    string contentUrl;
}

struct InstallArtifactRequest {
    TenantId tenantId;
    ArtifactId artifactId;  
}
