/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.execution;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct Execution {
    mixin TenantEntity!(ExecutionId);

    CommandId commandId;
    ExecutionStatus status = ExecutionStatus.pending;
    ExecutionPriority priority = ExecutionPriority.medium;
    string inputValues;
    string outputValues;
    string logs;
    string startedAt;
    string completedAt;
    string duration;
    string errorMessage;
    string triggeredBy;
    string retryAttempt;

    Json toJson() const {
        return entityToJson
            .set("commandId", commandId.value)
            .set("status", status.to!string())
            .set("priority", priority.to!string())
            .set("inputValues", inputValues)
            .set("outputValues", outputValues)
            .set("logs", logs)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("duration", duration)
            .set("errorMessage", errorMessage)
            .set("triggeredBy", triggeredBy)
            .set("retryAttempt", retryAttempt);
    }

}
