module uim.platform.job_scheduling.domain.enumerations;

// --- Enums ---

enum JobType {
    httpEndpoint,
    cloudFoundryTask,
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

enum JobScheduleStatus {
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
