/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation.domain.types;

// --- Generic result ---

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Situation Template ---

struct CreateSituationTemplateRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string defaultSeverity;
    string entityTypeId;
    string sourceSystem;
    string sourceTemplateId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    string createdBy;
}

struct UpdateSituationTemplateRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string defaultSeverity;
    string entityTypeId;
    int autoResolveTimeoutMinutes;
    bool escalationEnabled;
    string escalationTargetUserId;
    string modifiedBy;
}

// --- Situation Instance ---

struct CreateSituationInstanceRequest {
    string tenantId;
    string templateId;
    string id;
    string description;
    string severity;
    string entityId;
    string entityTypeId;
    string[][] contextData;
    string assignedTo;
    string sourceSystem;
    string sourceInstanceId;
    long dueAt;
}

struct UpdateSituationInstanceRequest {
    string tenantId;
    string id;
    string status;
    string severity;
    string assignedTo;
}

struct ResolveSituationRequest {
    string tenantId;
    string id;
    string resolutionType;
    string resolvedBy;
    string actionId;
    string ruleId;
    string outcome;
}

// --- Situation Action ---

struct CreateSituationActionRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string type;
    string baseUrl;
    string path;
    string method;
    string authType;
    string destinationName;
    string webhookUrl;
    string emailTemplate;
    string scriptContent;
    string createdBy;
}

struct UpdateSituationActionRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string baseUrl;
    string path;
    string authType;
    string destinationName;
    string webhookUrl;
    string emailTemplate;
    string modifiedBy;
}

// --- Automation Rule ---

struct CreateAutomationRuleRequest {
    string tenantId;
    string templateId;
    string id;
    string name;
    string description;
    string priority;
    int executionOrder;
    string createdBy;
}

struct UpdateAutomationRuleRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string priority;
    int executionOrder;
    bool enabled;
    string modifiedBy;
}

// --- Entity Type ---

struct CreateEntityTypeRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string sourceSystem;
    string createdBy;
}

struct UpdateEntityTypeRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string category;
    string modifiedBy;
}

// --- Data Context ---

struct CreateDataContextRequest {
    string tenantId;
    string instanceId;
    string id;
    string entityId;
    string entityTypeId;
    string[][] data;
    string sourceSystem;
    bool containsPersonalData;
    long expiresAt;
}

struct DeleteDataContextRequest {
    string tenantId;
    string id;
}

// --- Notification ---

struct CreateNotificationRequest {
    string tenantId;
    string instanceId;
    string id;
    string recipientId;
    string title;
    string message;
    string channel;
    string priority;
    string actionUrl;
}

struct UpdateNotificationRequest {
    string tenantId;
    string id;
    string status;
}

// --- Dashboard ---

struct CreateDashboardRequest {
    string tenantId;
    string id;
    string name;
    string description;
    string type;
    int refreshIntervalSeconds;
    string createdBy;
}

struct UpdateDashboardRequest {
    string tenantId;
    string id;
    string name;
    string description;
    int refreshIntervalSeconds;
    string modifiedBy;
}
