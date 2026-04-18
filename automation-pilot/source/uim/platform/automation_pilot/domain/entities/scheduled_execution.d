/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.scheduled_execution;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct ScheduledExecution {
    ScheduledExecutionId id;
    TenantId tenantId;
    CommandId commandId;
    ScheduleType scheduleType = ScheduleType.oneTime;
    ScheduleStatus status = ScheduleStatus.active;
    string cronExpression;
    string scheduledAt;
    string lastRunAt;
    string nextRunAt;
    string inputValues;
    string description;
    string maxRetries;
    string retryDelay;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;

    Json scheduledExecutionToJson() {
        return Json.emptyObject
            .set("id", id)
            .set("tenantId", tenantId)
            .set("commandId", commandId)
            .set("scheduleType", scheduleType.to!string)
            .set("status", status.to!string)
            .set("cronExpression", cronExpression)
            .set("scheduledAt", scheduledAt)
            .set("lastRunAt", lastRunAt)
            .set("nextRunAt", nextRunAt)
            .set("inputValues", inputValues)
            .set("description", description)
            .set("maxRetries", maxRetries)
            .set("retryDelay", retryDelay)
            .set("createdBy", createdBy)
            .set("modifiedBy", modifiedBy)
            .set("createdAt", createdAt)
            .set("modifiedAt", modifiedAt);
    }
}
