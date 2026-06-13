/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.dto;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

struct CatalogDTO {
    CatalogId catalogId;
    TenantId tenantId;
    string name;
    string description;
    string status;
    string catalogType;
    string tags;
    string version_;
    UserId createdBy;
    UserId updatedBy;
}

struct CommandDTO {
    CommandId commandId;
    TenantId tenantId;
    CatalogId catalogId;
    string name;
    string description;
    string status;
    string commandType;
    string version_;
    string inputSchema;
    string outputSchema;
    string steps;
    string timeout;
    string retryCount;
    string tags;
    UserId createdBy;
    UserId updatedBy;
}

struct CommandInputDTO {
    CommandInputId inputId;
    TenantId tenantId;
    string name;
    string description;
    string inputType;
    string sensitivity;
    string keys;
    string values;
    string version_;
    CommandId commandId;
    UserId createdBy;
    UserId updatedBy;
}

struct ExecutionDTO {
    ExecutionId executionId;
    TenantId tenantId;
    CommandId commandId;
    string status;
    string priority;
    string inputValues;
    UserId triggeredBy;
    UserId createdBy;
}

struct ScheduledExecutionDTO {
    ScheduledExecutionId executionId;
    TenantId tenantId;
    CommandId commandId;
    string scheduleType;
    string status;
    string cronExpression;
    long scheduledAt;
    string inputValues;
    string description;
    string maxRetries;
    string retryDelay;
    UserId createdBy;
    UserId updatedBy;
}

struct TriggerDTO {
    TriggerId triggerId;
    TenantId tenantId;
    CommandId commandId;
    string name;
    string description;
    string triggerType;
    string status;
    string eventType;
    string eventSource;
    string filterExpression;
    string inputMapping;
    UserId createdBy;
    UserId updatedBy;
}

struct ServiceAccountDTO {
    ServiceAccountId accountId;
    TenantId tenantId;
    string name;
    string description;
    string status;
    string clientId;
    string permissions;
    long expiresAt;
    UserId createdBy;
    UserId updatedBy;
}

struct ContentConnectorDTO {
    ContentConnectorId connectorId;
    TenantId tenantId;
    string name;
    string description;
    string connectorType;
    string repositoryUrl;
    string branch;
    string path;
    UserId createdBy;
    UserId updatedBy;
}
