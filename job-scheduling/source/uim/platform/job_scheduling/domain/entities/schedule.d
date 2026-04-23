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
    TenantId tenantId;
    ScheduleId id;
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
    long createdAt;
    long modifiedAt;

    static Schedule createFromRequest(CreateScheduleRequest request) {
        Schedule schedule;
        schedule.id = randomUUID();
        schedule.jobId = request.jobId;
        schedule.tenantId = request.tenantId;
        schedule.description = request.description;
        schedule.type = request.type.to!ScheduleType;
        schedule.format = request.format.to!ScheduleFormat;
        schedule.status = request.active ? ScheduleStatus.active : ScheduleStatus.inactive;
        schedule.active = request.active;
        schedule.cronExpression = request.cronExpression;
        schedule.humanReadableSchedule = request.humanReadableSchedule;
        schedule.repeatInterval = request.repeatInterval;
        schedule.repeatAt = request.repeatAt;
        schedule.time = request.time;
        schedule.startTime = request.startTime;
        schedule.endTime = request.endTime;
        schedule.createdAt = now;
        schedule.modifiedAt = now;

        return schedule;
    }
}
