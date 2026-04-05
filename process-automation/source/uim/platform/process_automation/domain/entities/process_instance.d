/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.process_instance;

import uim.platform.process_automation.domain.types;

struct ContextVariable {
    string name;
    string value;
    string type;
}

struct ExecutionLog {
    string stepId;
    string stepName;
    string status;
    string message;
    long startedAt;
    long completedAt;
}

struct ProcessInstance {
    ProcessInstanceId id;
    ProcessId processId;
    TenantId tenantId;
    string processName;
    InstanceStatus status;
    InstancePriority priority;
    string startedBy;
    string currentStepId;
    ContextVariable[] context;
    ExecutionLog[] executionLogs;
    string errorMessage;
    int retryCount;
    long startedAt;
    long completedAt;
    long dueDate;
}
