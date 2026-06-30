module uim.platform.job_scheduling.domain.enumerations;

import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:

enum JobType {
    httpEndpoint,
    cloudFoundryTask,
}
JobType toJobType(string s) @safe {
    mixin(EnumSwitch("JobType", "JobType.httpEndpoint"));
}
JobType[] toJobType(string[] values) @safe {
    return values.map!(v => v.toJobType).array;
}
string toString(JobType value) @safe {
    return value.to!string();
}
string[] toString(JobType[] values) @safe {
    return values.map!(v => v.toString).array;
}
///     
unittest {
    mixin(ShowTest!("JobType"));

    assert("httpEndpoint".toJobType == JobType.httpEndpoint);
    assert("cloudFoundryTask".toJobType == JobType.cloudFoundryTask);

    assert(JobType.httpEndpoint.toString == "httpEndpoint");
    assert(JobType.cloudFoundryTask.toString == "cloudFoundryTask");

    assert(["httpEndpoint", "cloudFoundryTask"].toJobType == [JobType.httpEndpoint, JobType.cloudFoundryTask]);
    assert([JobType.httpEndpoint, JobType.cloudFoundryTask].toString == ["httpEndpoint", "cloudFoundryTask"]);
}

enum JobTriggerType {
    timeBased,
    eventBased,
}
JobTriggerType toJobTriggerType(string s) @safe {
    mixin(EnumSwitch("JobTriggerType", "JobTriggerType.timeBased"));
}
JobTriggerType[] toJobTriggerType(string[] values) @safe {
    return values.map!(v => v.toJobTriggerType).array;
}
string toString(JobTriggerType value) @safe {
    return value.to!string();
}
string[] toString(JobTriggerType[] values) @safe {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("JobTriggerType"));

    assert("timeBased".toJobTriggerType == JobTriggerType.timeBased);
    assert("eventBased".toJobTriggerType == JobTriggerType.eventBased);

    assert(JobTriggerType.timeBased.toString == "timeBased");
    assert(JobTriggerType.eventBased.toString == "eventBased");

    assert([ "timeBased", "eventBased"].toJobTriggerType == [JobTriggerType.timeBased, JobTriggerType.eventBased]);
    assert([JobTriggerType.timeBased, JobTriggerType.eventBased].toString == ["timeBased", "eventBased"]);
}

enum JobStatus {
    active,
    inactive,
}
JobStatus toJobStatus(string s) @safe {
    mixin(EnumSwitch("JobStatus", "JobStatus.active"));
}
JobStatus[] toJobStatus(string[] values) @safe {
    return values.map!(v => v.toJobStatus).array;
}
string toString(JobStatus value) @safe {
    return value.to!string();
}
string[] toString(JobStatus[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("JobStatus"));

    assert("active".toJobStatus == JobStatus.active);
    assert("inactive".toJobStatus == JobStatus.inactive);   

    assert(JobStatus.active.toString == "active");
    assert(JobStatus.inactive.toString == "inactive");

    assert(["active", "inactive"].toJobStatus == [JobStatus.active, JobStatus.inactive]);
    assert([JobStatus.active, JobStatus.inactive].toString == ["active", "inactive"]);
}

enum ScheduleType {
    oneTime,
    recurring,
}
ScheduleType toScheduleType(string s) @safe {
    mixin(EnumSwitch("ScheduleType", "ScheduleType.oneTime"));
}
ScheduleType[] toScheduleType(string[] values) @safe {
    return values.map!(v => v.toScheduleType).array;
}
string toString(ScheduleType value) @safe {
    return value.to!string();
}
string[] toString(ScheduleType[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("ScheduleType"));

    assert("oneTime".toScheduleType == ScheduleType.oneTime);
    assert("recurring".toScheduleType == ScheduleType.recurring);   

    assert(ScheduleType.oneTime.toString == "oneTime");
    assert(ScheduleType.recurring.toString == "recurring");

    assert(["oneTime", "recurring"].toScheduleType == [ScheduleType.oneTime, ScheduleType.recurring]);
    assert([ScheduleType.oneTime, ScheduleType.recurring].toString == ["oneTime", "recurring"]);
}

enum ScheduleFormat {
    cron,
    humanReadable,
    repeatInterval,
    repeatAt,
}
ScheduleFormat toScheduleFormat(string s) @safe {
    mixin(EnumSwitch("ScheduleFormat", "ScheduleFormat.cron"));
}
ScheduleFormat[] toScheduleFormat(string[] values) @safe {
    return values.map!(v => v.toScheduleFormat).array;
}
string toString(ScheduleFormat value) @safe {
    return value.to!string();
}
string[] toString(ScheduleFormat[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("ScheduleFormat"));

    assert("cron".toScheduleFormat == ScheduleFormat.cron);
    assert("humanReadable".toScheduleFormat == ScheduleFormat.humanReadable);
    assert("repeatInterval".toScheduleFormat == ScheduleFormat.repeatInterval);
    assert("repeatAt".toScheduleFormat == ScheduleFormat.repeatAt);
    assert("unknown".toScheduleFormat == ScheduleFormat.cron);

    assert(ScheduleFormat.cron.toString == "cron");
    assert(ScheduleFormat.humanReadable.toString == "humanReadable");
    assert(ScheduleFormat.repeatInterval.toString == "repeatInterval");
    assert(ScheduleFormat.repeatAt.toString == "repeatAt");

    assert(["cron", "humanReadable", "repeatInterval", "repeatAt"].toScheduleFormat == [ScheduleFormat.cron, ScheduleFormat.humanReadable, ScheduleFormat.repeatInterval, ScheduleFormat.repeatAt]);
    assert([ScheduleFormat.cron, ScheduleFormat.humanReadable, ScheduleFormat.repeatInterval, ScheduleFormat.repeatAt].toString == ["cron", "humanReadable", "repeatInterval", "repeatAt"]);
}

enum JobScheduleStatus {
    active,
    inactive,
}
JobScheduleStatus toJobScheduleStatus(string s) @safe {
    mixin(EnumSwitch("JobScheduleStatus", "JobScheduleStatus.active"));
}
JobScheduleStatus[] toJobScheduleStatus(string[] values) @safe {
    return values.map!(v => v.toJobScheduleStatus).array;
}
string toString(JobScheduleStatus value) @safe {
    return value.to!string();
}
string[] toString(JobScheduleStatus[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("JobScheduleStatus"));

    assert("active".toJobScheduleStatus == JobScheduleStatus.active);
    assert("inactive".toJobScheduleStatus == JobScheduleStatus.inactive);

    assert(JobScheduleStatus.active.toString == "active");
    assert(JobScheduleStatus.inactive.toString == "inactive");

    assert(["active", "inactive"].toJobScheduleStatus == [JobScheduleStatus.active, JobScheduleStatus.inactive]);
    assert([JobScheduleStatus.active, JobScheduleStatus.inactive].toString == ["active", "inactive"]);
}

enum RunStatus {
    scheduled,
    triggered,
    running,
    completed,
    failed,
    deadLettered,
}
RunStatus toRunStatus(string s) @safe {
    mixin(EnumSwitch("RunStatus", "RunStatus.scheduled"));
}
RunStatus[] toRunStatus(string[] values) @safe {
    return values.map!(v => v.toRunStatus).array;
}
string toString(RunStatus value) @safe {
    return value.to!string();
}
string[] toString(RunStatus[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("RunStatus"));

    assert("scheduled".toRunStatus == RunStatus.scheduled);
    assert("triggered".toRunStatus == RunStatus.triggered);
    assert("running".toRunStatus == RunStatus.running);
    assert("completed".toRunStatus == RunStatus.completed);
    assert("failed".toRunStatus == RunStatus.failed);
    assert("deadLettered".toRunStatus == RunStatus.deadLettered);
    assert("unknown".toRunStatus == RunStatus.scheduled);

    assert(RunStatus.scheduled.toString == "scheduled");
    assert(RunStatus.triggered.toString == "triggered");
    assert(RunStatus.running.toString == "running");
    assert(RunStatus.completed.toString == "completed");
    assert(RunStatus.failed.toString == "failed");
    assert(RunStatus.deadLettered.toString == "deadLettered");

    assert(["scheduled", "triggered", "running", "completed", "failed", "deadLettered"].toRunStatus == [RunStatus.scheduled, RunStatus.triggered, RunStatus.running, RunStatus.completed, RunStatus.failed, RunStatus.deadLettered]);
    assert([RunStatus.scheduled, RunStatus.triggered, RunStatus.running, RunStatus.completed, RunStatus.failed, RunStatus.deadLettered].toString == ["scheduled", "triggered", "running", "completed", "failed", "deadLettered"]);
}