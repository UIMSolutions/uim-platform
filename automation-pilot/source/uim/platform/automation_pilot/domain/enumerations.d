/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.enumerations;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

enum CatalogStatus {
    active,
    inactive,
    archived
}

enum CatalogType {
    builtIn,
    custom
}

enum CommandStatus {
    draft,
    released,
    deprecated_
}

enum CommandType {
    simple,
    composite,
    httpRequest,
    script
}

enum ExecutionStatus {
    pending,
    running,
    completed,
    failed,
    cancelled,
    timedOut
}

enum ExecutionPriority {
    low,
    medium,
    high,
    critical
}

enum ScheduleType {
    oneTime,
    recurring,
    cron
}

enum ScheduleStatus {
    active,
    paused,
    completed,
    expired
}

enum TriggerType {
    event,
    webhook,
    alertNotification,
    manual
}

enum TriggerStatus {
    active,
    inactive,
    disabled
}

enum InputType {
    string_,
    integer,
    boolean_,
    json,
    secret
}

enum InputSensitivity {
    normal,
    sensitive,
    secret
}

enum ServiceAccountStatus {
    active,
    inactive,
    revoked
}

enum ConnectorType {
    github,
    gitLab,
    bitbucket,
    s3
}

enum ConnectorStatus {
    connected,
    disconnected,
    error
}

enum BackupStatus {
    pending,
    inProgress,
    completed,
    failed
}
