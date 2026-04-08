/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.types;

// --- ID aliases ---

struct JobId {
    string value;
    
    this(string value) {
        this.value = value;
    }
    
    mixin DomainId;
}
struct ScheduleId {
    string value;
    
    this(string value) {
        this.value = value;
    }
    
    mixin DomainId;
}
struct RunLogId {
    string value;
    
    this(string value) {
        this.value = value;
    }
    
    mixin DomainId;
}
struct TenantId {
    string value;
    
    this(string value) {
        this.value = value;
    }
    
    mixin DomainId;
}
struct ConfigId {
    string value;
    
    this(string value) {
        this.value = value;
    }
    
    mixin DomainId;
}

// --- Enums ---

enum JobType {
    httpEndpoint,
    cloudFoundryTask,
}

enum HttpMethod {
    get,
    post,
    put,
    delete_,
    patch,
}

enum JobStatus {
    active,
    inactive,
}

enum ScheduleType {
    oneTime,
    recurring,
}

enum ScheduleFormat {
    cron,
    humanReadable,
    repeatInterval,
    repeatAt,
}

enum ScheduleStatus {
    active,
    inactive,
}

enum RunStatus {
    scheduled,
    triggered,
    running,
    completed,
    failed,
    deadLettered,
}
