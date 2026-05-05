/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.schedule;

// import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
struct Schedule {
            mixin TenantEntity!ScheduleId;
    
    JobId jobId;
    string description;
    ScheduleType type;
    ScheduleFormat format;
    ScheduleStatus status;
    bool active;
    string cronExpression;
    string humanReadableSchedule;
    long repeatInterval;
    string repeatAt;
    string time;
    long startTime;
    long endTime;
    long nextRunAt;

    Json toJson() const {
        return entityToJson
            .set("jobId", jobId)
            .set("description", description)
            .set("type", type.to!string())
            .set("format", format.to!string())
            .set("status", status.to!string())
            .set("active", active)
            .set("cronExpression", cronExpression)
            .set("humanReadableSchedule", humanReadableSchedule)
            .set("repeatInterval", repeatInterval)
            .set("repeatAt", repeatAt)
            .set("time", time)
            .set("startTime", startTime)
            .set("endTime", endTime)
            .set("nextRunAt", nextRunAt);
    }
}
