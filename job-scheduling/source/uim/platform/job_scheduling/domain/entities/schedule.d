/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.schedule;

import uim.platform.job_scheduling.domain.types;

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
}
