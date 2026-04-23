module uim.platform.job_scheduling.domain.enumerations;

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
