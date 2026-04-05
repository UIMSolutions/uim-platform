/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.run_log;

import uim.platform.job_scheduling.domain.types;

struct RunLog {
    RunLogId id;
    ScheduleId scheduleId;
    JobId jobId;
    TenantId tenantId;
    RunStatus status;
    string statusMessage;
    int httpStatus;
    long scheduledAt;
    long triggeredAt;
    long completedAt;
    long executionDurationMs;
    long createdAt;
}
