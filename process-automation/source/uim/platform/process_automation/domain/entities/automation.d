/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.automation;

import uim.platform.process_automation.domain.types;

struct AutomationStep {
    string id;
    string name;
    string type;
    string application;
    string activity;
    string[] parameters;
    string[] nextSteps;
    int retryCount;
    int timeoutSeconds;
}

struct AutomationRun {
    string id;
    AutomationId automationId;
    AutomationRunStatus status;
    string triggeredBy;
    string agentId;
    string inputData;
    string outputData;
    string errorMessage;
    long startedAt;
    long completedAt;
}

struct Automation {
    AutomationId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    AutomationStatus status;
    AutomationType type;
    AutomationStep[] steps;
    string targetApplication;
    string version_;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
