module uim.platform.job_scheduling.domain.enumerations;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

enum JobType {
    httpEndpoint,
    cloudFoundryTask,
}
JobType toJobType(string value) @safe {
    mixin(EnumSwitch("JobType", "httpEndpoint"));
}
JobType[] toJobTypes(string[] values) @safe {
    return values.map!(v => v.toJobType).array;
}
string toString(JobType value) @safe {
    return value.to!string();
}
string[] toStrings(JobType[] values) @safe {
    return values.map!(v => v.toString).array;
}
///     
unittest {
    mixin(ShowTest!("JobType"));

    assert("httpEndpoint".toJobType == JobType.httpEndpoint);
    assert("cloudFoundryTask".toJobType == JobType.cloudFoundryTask);

    assert(JobType.httpEndpoint.toString == "httpEndpoint");
    assert(JobType.cloudFoundryTask.toString == "cloudFoundryTask");

    assert(["httpEndpoint", "cloudFoundryTask"].toJobTypes == [JobType.httpEndpoint, JobType.cloudFoundryTask]);
    assert([JobType.httpEndpoint, JobType.cloudFoundryTask].toStrings == ["httpEndpoint", "cloudFoundryTask"]);
}

enum JobTriggerType {
    timeBased,
    eventBased,
}
JobTriggerType toJobTriggerType(string value) @safe {
    mixin(EnumSwitch("JobTriggerType", "timeBased"));
}
JobTriggerType[] toJobTriggerTypes(string[] values) @safe {
    return values.map!(v => v.toJobTriggerType).array;
}
string toString(JobTriggerType value) @safe {
    return value.to!string();
}
string[] toStrings(JobTriggerType[] values) @safe {
    return values.map!(v => v.toString).array;
}
///
unittest {
    mixin(ShowTest!("JobTriggerType"));

    assert("timeBased".toJobTriggerType == JobTriggerType.timeBased);
    assert("eventBased".toJobTriggerType == JobTriggerType.eventBased);

    assert(JobTriggerType.timeBased.toString == "timeBased");
    assert(JobTriggerType.eventBased.toString == "eventBased");

    assert([ "timeBased", "eventBased"].toJobTriggerTypes == [JobTriggerType.timeBased, JobTriggerType.eventBased]);
    assert([JobTriggerType.timeBased, JobTriggerType.eventBased].toStrings == ["timeBased", "eventBased"]);
}

enum JobStatus {
    active,
    inactive,
}
JobStatus toJobStatus(string value) @safe {
    mixin(EnumSwitch("JobStatus", "active"));
}
JobStatus[] toJobStatuses(string[] values) @safe {
    return values.map!(v => v.toJobStatus).array;
}
string toString(JobStatus value) @safe {
    return value.to!string();
}
string[] toStrings(JobStatus[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("JobStatus"));

    assert("active".toJobStatus == JobStatus.active);
    assert("inactive".toJobStatus == JobStatus.inactive);   

    assert(JobStatus.active.toString == "active");
    assert(JobStatus.inactive.toString == "inactive");

    assert(["active", "inactive"].toJobStatuses == [JobStatus.active, JobStatus.inactive]);
    assert([JobStatus.active, JobStatus.inactive].toStrings == ["active", "inactive"]);
}

enum ScheduleType {
    oneTime,
    recurring,
}
ScheduleType toScheduleType(string value) @safe {
    mixin(EnumSwitch("ScheduleType", "oneTime"));
}
ScheduleType[] toScheduleTypes(string[] values) @safe {
    return values.map!(v => v.toScheduleType).array;
}
string toString(ScheduleType value) @safe {
    return value.to!string();
}
string[] toStrings(ScheduleType[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("ScheduleType"));

    assert("oneTime".toScheduleType == ScheduleType.oneTime);
    assert("recurring".toScheduleType == ScheduleType.recurring);   

    assert(ScheduleType.oneTime.toString == "oneTime");
    assert(ScheduleType.recurring.toString == "recurring");

    assert(["oneTime", "recurring"].toScheduleTypes == [ScheduleType.oneTime, ScheduleType.recurring]);
    assert([ScheduleType.oneTime, ScheduleType.recurring].toStrings == ["oneTime", "recurring"]);
}

enum ScheduleFormat {
    cron,
    humanReadable,
    repeatInterval,
    repeatAt,
}
ScheduleFormat toScheduleFormat(string value) @safe {
    mixin(EnumSwitch("ScheduleFormat", "cron"));
}
ScheduleFormat[] toScheduleFormats(string[] values) @safe {
    return values.map!(v => v.toScheduleFormat).array;
}
string toString(ScheduleFormat value) @safe {
    return value.to!string();
}
string[] toStrings(ScheduleFormat[] values) @safe {
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

    assert(["cron", "humanReadable", "repeatInterval", "repeatAt"].toScheduleFormats == [ScheduleFormat.cron, ScheduleFormat.humanReadable, ScheduleFormat.repeatInterval, ScheduleFormat.repeatAt]);
    assert([ScheduleFormat.cron, ScheduleFormat.humanReadable, ScheduleFormat.repeatInterval, ScheduleFormat.repeatAt].toStrings == ["cron", "humanReadable", "repeatInterval", "repeatAt"]);
}

enum JobScheduleStatus {
    active,
    inactive,
}
JobScheduleStatus toJobScheduleStatus(string value) @safe {
    mixin(EnumSwitch("JobScheduleStatus", "active"));
}
JobScheduleStatus[] toJobScheduleStatuses(string[] values) @safe {
    return values.map!(v => v.toJobScheduleStatus).array;
}
string toString(JobScheduleStatus value) @safe {
    return value.to!string();
}
string[] toStrings(JobScheduleStatus[] values) @safe {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("JobScheduleStatus"));

    assert("active".toJobScheduleStatus == JobScheduleStatus.active);
    assert("inactive".toJobScheduleStatus == JobScheduleStatus.inactive);

    assert(JobScheduleStatus.active.toString == "active");
    assert(JobScheduleStatus.inactive.toString == "inactive");

    assert(["active", "inactive"].toJobScheduleStatuses == [JobScheduleStatus.active, JobScheduleStatus.inactive]);
    assert([JobScheduleStatus.active, JobScheduleStatus.inactive].toStrings == ["active", "inactive"]);
}

enum RunStatus {
    scheduled,
    triggered,
    running,
    completed,
    failed,
    deadLettered,
}
RunStatus toRunStatus(string value) @safe {
    mixin(EnumSwitch("RunStatus", "scheduled"));
}
RunStatus[] toRunStatuses(string[] values) @safe {
    return values.map!(v => v.toRunStatus).array;
}
string toString(RunStatus value) @safe {
    return value.to!string();
}
string[] toStrings(RunStatus[] values) @safe {
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

    assert(["scheduled", "triggered", "running", "completed", "failed", "deadLettered"].toRunStatuses == [RunStatus.scheduled, RunStatus.triggered, RunStatus.running, RunStatus.completed, RunStatus.failed, RunStatus.deadLettered]);
    assert([RunStatus.scheduled, RunStatus.triggered, RunStatus.running, RunStatus.completed, RunStatus.failed, RunStatus.deadLettered].toStrings == ["scheduled", "triggered", "running", "completed", "failed", "deadLettered"]);
}