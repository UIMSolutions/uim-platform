/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.application.dto;

import uim.platform.job_scheduling.domain.types;

// --- Generic result ---

struct CommandResult {
    bool success;
    string id;
    string error;
}

// --- Job ---

struct CreateJobRequest {
    string tenantId;
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
    string tenantId;
    string jobId;
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
    string tenantId;
    string jobId;
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
    string tenantId;
    string jobId;
    string scheduleId;
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
    string tenantId;
    string status;
    string statusMessage;
    int httpStatus;
    long completedAt;
    long executionDurationMs;
}

// --- Configuration ---

struct UpdateConfigurationRequest {
    string tenantId;
    int defaultRetries;
    long defaultRetryDelayMs;
    long maxRunDurationMs;
    bool enableAsyncMode;
    bool enableAlertNotifications;
}

// --- Bulk operations ---

struct ActivateAllSchedulesRequest {
    string tenantId;
    string jobId;
    bool active;
}
