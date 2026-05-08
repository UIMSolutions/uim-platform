/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.entities.process_instance;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:

struct ContextVariable {
    string name;
    string value;
    string type;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("value", value)
            .set("type", type);
    }
}

struct ExecutionLog {
    ProcessStepId stepId;
    string stepName;
    string status;
    string message;
    long startedAt;
    long completedAt;

    Json toJson() const {
        return Json.emptyObject
            .set("stepId", stepId.value)
            .set("stepName", stepName)
            .set("status", status)
            .set("message", message)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt);
    }
}

struct ProcessInstance {
    mixin TenantEntity!(ProcessInstanceId);

    ProcessId processId;
    string processName;
    InstanceStatus status;
    InstancePriority priority;
    UserId startedBy;
    ProcessStepId currentStepId;
    ContextVariable[] context;
    ExecutionLog[] executionLogs;
    string errorMessage;
    int retryCount;
    long startedAt;
    long completedAt;
    long dueDate;

    Json toJson() const {
        auto j = entityToJson
            .set("processId", processId.value)
            .set("processName", processName)
            .set("status", status.to!string())
            .set("priority", priority.to!string())
            .set("startedBy", startedBy)
            .set("currentStepId", currentStepId.value)
            .set("context", context.map!(c => c.toJson()).array.toJson)
            .set("executionLogs", executionLogs.map!(log => log.toJson()).array.toJson)
            .set("errorMessage", errorMessage)
            .set("retryCount", retryCount)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("dueDate", dueDate);

        return j;
    }
}
