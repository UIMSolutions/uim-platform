/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.process;

import uim.platform.process_automation.domain.types;

struct ProcessStep {
    ProcessStepId id;
    string name;
    StepType type;
    string description;
    string assignee;
    string formId;
    string decisionId;
    string automationId;
    string[] nextSteps;
    string condition;
    int timeoutMinutes;
}

struct ProcessVariable {
    string name;
    string type;
    string defaultValue;
    bool required;
    string description;
}

struct Process {
    ProcessId id;
    TenantId tenantId;
    ProjectId projectId;
    string name;
    string description;
    ProcessStatus status;
    ProcessCategory category;
    string version_;
    ProcessStep[] steps;
    ProcessVariable[] variables;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
