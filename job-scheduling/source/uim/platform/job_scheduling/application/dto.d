/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.dto;

// import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
// --- Job ---

struct CreateJobRequest {
    TenantId tenantId;
    string name;
    string description;
    string actionUrl;
    string httpMethod;
    string type;
    bool active;
    long startTime;
    long endTime;
    // Inline schedules to create with the job
    CreateScheduleRequest[] schedules;
}

struct UpdateJobRequest {
    TenantId tenantId;
    JobId jobId;
    string name;
    string description;
    string actionUrl;
    string httpMethod;
    bool active;
    long startTime;
    long endTime;
}

// --- Schedule ---

struct CreateScheduleRequest {
    TenantId tenantId;
    JobId jobId;
    string description;
    string type;
    string format;
    bool active;
    string cronExpression;
    string humanReadableSchedule;
    long repeatInterval;
    string repeatAt;
    string time;
    long startTime;
    long endTime;
}

struct UpdateScheduleRequest {
    TenantId tenantId;
    JobId jobId;
    ScheduleId scheduleId;
    string description;
    bool active;
    string cronExpression;
    string humanReadableSchedule;
    long repeatInterval;
    string repeatAt;
    string time;
    long startTime;
    long endTime;
}

// --- Run Log ---

struct UpdateRunLogRequest {
    string runLogId;
    TenantId tenantId;
    string status;
    string statusMessage;
    int httpStatus;
    long completedAt;
    long executionDurationMs;
}

// --- Configuration ---

struct UpdateConfigurationRequest {
    TenantId tenantId;
    int defaultRetries;
    long defaultRetryDelayMs;
    long maxRunDurationMs;
    bool enableAsyncMode;
    bool enableAlertNotifications;
}

// --- Bulk operations ---

struct ActivateAllSchedulesRequest {
    TenantId tenantId;
    JobId jobId;
    bool active;
}
