/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.enumerations;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

enum CatalogType {
    system,
    custom
}

CatalogType toCatalogType(string value) {
    mixin(EnumSwitch("CatalogType", "custom"));
}

CatalogType[] toCatalogTypes(string[] s) {
    return s.map!(toCatalogType).array;
}

string toString(CatalogType type) {
    return type.to!string;
}

string[] toStrings(CatalogType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert(toCatalogType("system") == CatalogType.system);
    assert(toCatalogType("custom") == CatalogType.custom);
    assert(toCatalogType("") == CatalogType.custom);
    assert(toCatalogType("unknown") == CatalogType.custom);

    assert(toCatalogTypes(["system", "custom", "unknown"]) == [
            CatalogType.system, CatalogType.custom, CatalogType.custom
        ]);

    assert(toString(CatalogType.system) == "system");
    assert(toString(CatalogType.custom) == "custom");

    assert(toStrings([CatalogType.system, CatalogType.custom]) == [
            "system", "custom"
        ]);
}

enum CatalogStatus {
    active,
    inactive,
    archived
}

CatalogStatus toCatalogStatus(string value) {
    mixin(EnumSwitch("CatalogStatus", "active"));
}

CatalogStatus[] toCatalogStatuses(string[] s) {
    return s.map!(toCatalogStatus).array;
}

string toString(CatalogStatus status) {
    return status.to!string;
}

string[] toStrings(CatalogStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert(toCatalogStatus("active") == CatalogStatus.active);
    assert(toCatalogStatus("inactive") == CatalogStatus.inactive);
    assert(toCatalogStatus("archived") == CatalogStatus.archived);

    assert(toCatalogStatuses(["active", "inactive", "archived"]) == [
            CatalogStatus.active, CatalogStatus.inactive, CatalogStatus.archived
        ]);

    assert(toString(CatalogStatus.active) == "active");
    assert(toString(CatalogStatus.inactive) == "inactive");
    assert(toString(CatalogStatus.archived) == "archived");

    assert(toStrings([
            CatalogStatus.active, CatalogStatus.inactive, CatalogStatus.archived
        ]) == ["active", "inactive", "archived"]);
}

enum CommandStatus : string {
    active = "active",
    inactive = "inactive",
    draft = "draft",
    deprecated_ = "deprecated"
}

CommandStatus toCommandStatus(string value) {
    switch (value.toLower) {
    case "active":
        return CommandStatus.active;
    case "inactive":
        return CommandStatus.inactive;
    case "draft":
        return CommandStatus.draft;
    case "deprecated":
        return CommandStatus.deprecated_;
    default:
        return CommandStatus.active;
    }
}

CommandStatus[] toCommandStatuses(string[] s) {
    return s.map!(toCommandStatus).array;
}

string toString(CommandStatus status) {
    return cast(string)status;
}

string[] toStrings(CommandStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("active".toCommandStatus == CommandStatus.active);
    assert("inactive".toCommandStatus == CommandStatus.inactive);
    assert("draft".toCommandStatus == CommandStatus.draft);
    assert("deprecated".toCommandStatus == CommandStatus.deprecated_);

    assert("".toCommandStatus == CommandStatus.active);
    assert("unknown".toCommandStatus == CommandStatus.active);

    assert(["active", "inactive", "deprecated", "unknown"].toCommandStatuses == [
            CommandStatus.active, CommandStatus.inactive,
            CommandStatus.deprecated_,
            CommandStatus.active
        ]);

    assert(CommandStatus.active.toString == "active");
    assert(CommandStatus.inactive.toString == "inactive");
    assert(CommandStatus.deprecated_.toString == "deprecated");

    assert([
            CommandStatus.active, CommandStatus.inactive,
            CommandStatus.deprecated_
        ].toStrings == ["active", "inactive", "deprecated"]);
}

enum CommandType {
    simple,
    composite,
    httpRequest,
    script
}

CommandType toCommandType(string value) {
    mixin(EnumSwitch("CommandType", "simple"));
}

CommandType[] toCommandTypes(string[] s) {
    return s.map!(toCommandType).array;
}

string toString(CommandType type) {
    return type.to!string;
}

string[] toStrings(CommandType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("simple".toCommandType == CommandType.simple);
    assert("composite".toCommandType == CommandType.composite);
    assert("httpRequest".toCommandType == CommandType.httpRequest);
    assert("script".toCommandType == CommandType.script);

    assert("".toCommandType == CommandType.simple);
    assert("unknown".toCommandType == CommandType.simple);

    assert([
            "simple", "composite", "httpRequest", "script", "unknown"
        ].toCommandTypes == [
        CommandType.simple, CommandType.composite, CommandType.httpRequest,
        CommandType.script, CommandType.simple
    ]);

    assert(CommandType.simple.toString == "simple");
    assert(CommandType.composite.toString == "composite");
    assert(CommandType.httpRequest.toString == "httpRequest");
    assert(CommandType.script.toString == "script");

    assert([
            CommandType.simple, CommandType.composite, CommandType.httpRequest,
            CommandType.script
        ].toStrings == ["simple", "composite", "httpRequest", "script"]);
}

enum ExecutionStatus {
    pending,
    running,
    completed,
    failed,
    cancelled,
    timedOut
}

ExecutionStatus toExecutionStatus(string value) {
    mixin(EnumSwitch("ExecutionStatus", "pending"));
}

ExecutionStatus[] toExecutionStatuses(string[] s) {
    return s.map!toExecutionStatus.array;
}

string toString(ExecutionStatus status) {
    return status.to!string;
}

string[] toStrings(ExecutionStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("pending".toExecutionStatus == ExecutionStatus.pending);
    assert("running".toExecutionStatus == ExecutionStatus.running);
    assert("completed".toExecutionStatus == ExecutionStatus.completed);
    assert("failed".toExecutionStatus == ExecutionStatus.failed);
    assert("cancelled".toExecutionStatus == ExecutionStatus.cancelled);
    assert("timedOut".toExecutionStatus == ExecutionStatus.timedOut);

    assert("".toExecutionStatus == ExecutionStatus.pending);
    assert("unknown".toExecutionStatus == ExecutionStatus.pending);

    assert([
            "pending", "running", "completed", "failed", "cancelled", "timedOut",
            "unknown"
        ].toExecutionStatuses == [
        ExecutionStatus.pending, ExecutionStatus.running,
        ExecutionStatus.completed, ExecutionStatus.failed,
        ExecutionStatus.cancelled, ExecutionStatus.timedOut,
        ExecutionStatus.pending
    ]);

    assert(ExecutionStatus.pending.toString == "pending");
    assert(ExecutionStatus.running.toString == "running");
    assert(ExecutionStatus.completed.toString == "completed");
    assert(ExecutionStatus.failed.toString == "failed");
    assert(ExecutionStatus.cancelled.toString == "cancelled");
    assert(ExecutionStatus.timedOut.toString == "timedOut");

    assert([
            ExecutionStatus.pending, ExecutionStatus.running,
            ExecutionStatus.completed, ExecutionStatus.failed,
            ExecutionStatus.cancelled, ExecutionStatus.timedOut
        ].toStrings == [
        "pending", "running", "completed", "failed", "cancelled", "timedOut"
    ]);
}

enum ExecutionPriority {
    low,
    medium,
    high,
    critical
}

ExecutionPriority toExecutionPriority(string value) {
    mixin(EnumSwitch("ExecutionPriority", "medium"));
}

ExecutionPriority[] toExecutionPriorities(string[] s) {
    return s.map!(toExecutionPriority).array;
}

string toString(ExecutionPriority priority) {
    return priority.to!string;
}

string[] toStrings(ExecutionPriority[] priorities) {
    return priorities.map!toString.array;
}
///
unittest {
    assert("low".toExecutionPriority == ExecutionPriority.low);
    assert("medium".toExecutionPriority == ExecutionPriority.medium);
    assert("high".toExecutionPriority == ExecutionPriority.high);
    assert("critical".toExecutionPriority == ExecutionPriority.critical);

    assert("".toExecutionPriority == ExecutionPriority.medium);
    assert("unknown".toExecutionPriority == ExecutionPriority.medium);

    assert([
            "low", "medium", "high", "critical", "unknown"
        ].toExecutionPriorities == [
        ExecutionPriority.low, ExecutionPriority.medium, ExecutionPriority.high,
        ExecutionPriority.critical, ExecutionPriority.medium
    ]);

    assert(ExecutionPriority.low.toString == "low");
    assert(ExecutionPriority.medium.toString == "medium");
    assert(ExecutionPriority.high.toString == "high");
    assert(ExecutionPriority.critical.toString == "critical");

    assert([
            ExecutionPriority.low, ExecutionPriority.medium,
            ExecutionPriority.high, ExecutionPriority.critical
        ].toStrings == ["low", "medium", "high", "critical"]);
}

enum ScheduleType {
    oneTime,
    recurring,
    cron
}

ScheduleType toScheduleType(string value) {
    mixin(EnumSwitch("ScheduleType", "oneTime"));
}

ScheduleType[] toScheduleTypes(string[] s) {
    return s.map!(toScheduleType).array;
}

string toString(ScheduleType type) {
    return type.to!string;
}

string[] toStrings(ScheduleType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("oneTime".toScheduleType == ScheduleType.oneTime);
    assert("recurring".toScheduleType == ScheduleType.recurring);
    assert("cron".toScheduleType == ScheduleType.cron);

    assert("".toScheduleType == ScheduleType.oneTime);
    assert("unknown".toScheduleType == ScheduleType.oneTime);

    assert(["oneTime", "recurring", "cron", "unknown"].toScheduleTypes == [
            ScheduleType.oneTime, ScheduleType.recurring, ScheduleType.cron,
            ScheduleType.oneTime
        ]);

    assert(ScheduleType.oneTime.toString == "oneTime");
    assert(ScheduleType.recurring.toString == "recurring");
    assert(ScheduleType.cron.toString == "cron");

    assert([
            ScheduleType.oneTime, ScheduleType.recurring, ScheduleType.cron
        ].toStrings == ["oneTime", "recurring", "cron"]);
}

enum ScheduleStatus {
    active,
    paused,
    completed,
    expired
}

ScheduleStatus toScheduleStatus(string value) {
    mixin(EnumSwitch("ScheduleStatus", "active"));
}

ScheduleStatus[] toScheduleStatuses(string[] s) {
    return s.map!(toScheduleStatus).array;
}

string toString(ScheduleStatus status) {
    return status.to!string;
}

string[] toStrings(ScheduleStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("active".toScheduleStatus == ScheduleStatus.active);
    assert("paused".toScheduleStatus == ScheduleStatus.paused);
    assert("completed".toScheduleStatus == ScheduleStatus.completed);
    assert("expired".toScheduleStatus == ScheduleStatus.expired);

    assert("".toScheduleStatus == ScheduleStatus.active);
    assert("unknown".toScheduleStatus == ScheduleStatus.active);

    assert([
            "active", "paused", "completed", "expired", "unknown"
        ].toScheduleStatuses == [
        ScheduleStatus.active, ScheduleStatus.paused, ScheduleStatus.completed,
        ScheduleStatus.expired, ScheduleStatus.active
    ]);

    assert(ScheduleStatus.active.toString == "active");
    assert(ScheduleStatus.paused.toString == "paused");
    assert(ScheduleStatus.completed.toString == "completed");
    assert(ScheduleStatus.expired.toString == "expired");

    assert([
            ScheduleStatus.active, ScheduleStatus.paused, ScheduleStatus.completed,
            ScheduleStatus.expired
        ].toStrings == ["active", "paused", "completed", "expired"]);
}

enum TriggerType {
    event,
    webhook,
    alertNotification,
    manual
}

TriggerType toTriggerType(string value) {
    mixin(EnumSwitch("TriggerType", "event"));
}

TriggerType[] toTriggerTypes(string[] s) {
    return s.map!(toTriggerType).array;
}

string toString(TriggerType type) {
    return type.to!string;
}

string[] toStrings(TriggerType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("event".toTriggerType == TriggerType.event);
    assert("webhook".toTriggerType == TriggerType.webhook);
    assert("alertNotification".toTriggerType == TriggerType.alertNotification);
    assert("manual".toTriggerType == TriggerType.manual);

    assert("".toTriggerType == TriggerType.event);
    assert("unknown".toTriggerType == TriggerType.event);

    assert(["event", "webhook", "alertNotification", "manual", "unknown"].toTriggerTypes == [
            TriggerType.event, TriggerType.webhook, TriggerType.alertNotification,
            TriggerType.manual, TriggerType.event
        ]);

    assert(TriggerType.event.toString == "event");
    assert(TriggerType.webhook.toString == "webhook");
    assert(TriggerType.alertNotification.toString == "alertNotification");
    assert(TriggerType.manual.toString == "manual");

    assert([
        TriggerType.event, TriggerType.webhook, TriggerType.alertNotification,
        TriggerType.manual
    ].toStrings == ["event", "webhook", "alertNotification", "manual"]);
}

enum TriggerStatus {
    active,
    inactive,
    disabled
}

TriggerStatus toTriggerStatus(string value) {
    mixin(EnumSwitch("TriggerStatus", "active"));
}

TriggerStatus[] toTriggerStatuses(string[] s) {
    return s.map!(toTriggerStatus).array;
}

string toString(TriggerStatus status) {
    return status.to!string;
}

string[] toStrings(TriggerStatus[] statuses) {
    return statuses.map!toString.array;
}

unittest {
    assert("active".toTriggerStatus == TriggerStatus.active);
    assert("inactive".toTriggerStatus == TriggerStatus.inactive);
    assert("disabled".toTriggerStatus == TriggerStatus.disabled);

    assert("".toTriggerStatus == TriggerStatus.active);
    assert("unknown".toTriggerStatus == TriggerStatus.active);

    assert(["active", "inactive", "disabled", "unknown"].toTriggerStatuses == [
            TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.disabled,
            TriggerStatus.active
        ]);

    assert(TriggerStatus.active.toString == "active");
    assert(TriggerStatus.inactive.toString == "inactive");
    assert(TriggerStatus.disabled.toString == "disabled");

    assert([
            TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.disabled
        ].toStrings == ["active", "inactive", "disabled"]);
}

enum InputType : string {
    string_ = "string",
    integer = "integer",
    boolean_ = "boolean",
    json = "json",
    secret = "secret"
}

InputType toInputType(string value) {
    switch (value.toLower) {
    case "string":
        return InputType.string_;
    case "integer":
        return InputType.integer;
    case "boolean":
        return InputType.boolean_;
    case "json":
        return InputType.json;
    case "secret":
        return InputType.secret;
    default:
        return InputType.string_;
    }
}

InputType[] toInputType(string[] values) {
    return values.map!(toInputType).array;
}

string toString(InputType type) {
    return type.to!string;
}

string[] toStrings(InputType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("string".toInputType == InputType.string_);
    assert("integer".toInputType == InputType.integer);
    assert("boolean".toInputType == InputType.boolean_);
    assert("json".toInputType == InputType.json);
    assert("secret".toInputType == InputType.secret);

    assert("".toInputType == InputType.string_);
    assert("unknown".toInputType == InputType.string_);

    assert(["string", "integer"].toInputType == [
            InputType.string_, InputType.integer
        ]);

    assert(InputType.string_.toString == "string");
    assert(InputType.integer.toString == "integer");
    assert(InputType.boolean_.toString == "boolean");
    assert(InputType.json.toString == "json");
    assert(InputType.secret.toString == "secret");

    assert([InputType.string_, InputType.integer].toStrings == [
            "string", "integer"
        ]);
}

enum InputSensitivity {
    normal,
    sensitive,
    secret
}

InputSensitivity toInputSensitivity(string value) {
    mixin(EnumSwitch("InputSensitivity", "normal"));
}

InputSensitivity[] toInputSensitivities(string[] values) {
    return values.map!(toInputSensitivity).array;
}

string toString(InputSensitivity sensitivity) {
    return sensitivity.to!string;
}

string[] toStrings(InputSensitivity[] sensitivities) {
    return sensitivities.map!toString.array;
}
///
unittest {
    assert("normal".toInputSensitivity == InputSensitivity.normal);
    assert("sensitive".toInputSensitivity == InputSensitivity.sensitive);
    assert("secret".toInputSensitivity == InputSensitivity.secret);

    assert("".toInputSensitivity == InputSensitivity.normal);
    assert("unknown".toInputSensitivity == InputSensitivity.normal);

    assert(["normal", "secret"].toInputSensitivities == [
            InputSensitivity.normal, InputSensitivity.secret
        ]);

    assert(InputSensitivity.normal.toString == "normal");
    assert(InputSensitivity.sensitive.toString == "sensitive");
    assert(InputSensitivity.secret.toString == "secret");

    assert([InputSensitivity.normal, InputSensitivity.secret].toStrings == [
            "normal", "secret"
        ]);
}

enum ServiceAccountStatus {
    active,
    inactive,
    revoked
}

ServiceAccountStatus toServiceAccountStatus(string value) {
    mixin(EnumSwitch("ServiceAccountStatus", "active"));
}

ServiceAccountStatus[] toServiceAccountStatuses(string[] values) {
    return values.map!(toServiceAccountStatus).array;
}

string toString(ServiceAccountStatus status) {
    return status.to!string;
}

string[] toStrings(ServiceAccountStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("active".toServiceAccountStatus == ServiceAccountStatus.active);
    assert("inactive".toServiceAccountStatus == ServiceAccountStatus.inactive);
    assert("revoked".toServiceAccountStatus == ServiceAccountStatus.revoked);

    assert("".toServiceAccountStatus == ServiceAccountStatus.active);
    assert("unknown".toServiceAccountStatus == ServiceAccountStatus.active);

    assert(["active", "inactive"].toServiceAccountStatuses == [
            ServiceAccountStatus.active, ServiceAccountStatus.inactive
        ]);

    assert(ServiceAccountStatus.active.toString == "active");
    assert(ServiceAccountStatus.inactive.toString == "inactive");
    assert(ServiceAccountStatus.revoked.toString == "revoked");

    assert([ServiceAccountStatus.active, ServiceAccountStatus.revoked].toStrings == [
            "active", "revoked"
        ]);
}

enum ConnectorType {
    github,
    gitLab,
    bitbucket,
    s3
}

ConnectorType toConnectorType(string value) {
    mixin(EnumSwitch("ConnectorType", "github"));
}

ConnectorType[] toConnectorTypes(string[] values) {
    return values.map!(toConnectorType).array;
}

string toString(ConnectorType type) {
    return type.to!string;
}

string[] toStrings(ConnectorType[] types) {
    return types.map!toString.array;
}
///
unittest {
    assert("github".toConnectorType == ConnectorType.github);
    assert("gitLab".toConnectorType == ConnectorType.gitLab);
    assert("bitbucket".toConnectorType == ConnectorType.bitbucket);
    assert("s3".toConnectorType == ConnectorType.s3);

    assert("".toConnectorType == ConnectorType.github);
    assert("unknown".toConnectorType == ConnectorType.github);

    assert(["github", "gitLab"].toConnectorTypes == [
            ConnectorType.github, ConnectorType.gitLab
        ]);

    assert(ConnectorType.github.toString == "github");
    assert(ConnectorType.gitLab.toString == "gitLab");
    assert(ConnectorType.bitbucket.toString == "bitbucket");
    assert(ConnectorType.s3.toString == "s3");

    assert([ConnectorType.github, ConnectorType.gitLab].toStrings == [
            "github", "gitLab"
        ]);
}

enum ConnectorStatus {
    connected,
    disconnected,
    error
}

ConnectorStatus toConnectorStatus(string value) {
    mixin(EnumSwitch("ConnectorStatus", "connected"));
}

ConnectorStatus[] toConnectorStatuses(string[] values) {
    return values.map!(toConnectorStatus).array;
}

string toString(ConnectorStatus status) {
    return status.to!string;
}

string[] toStrings(ConnectorStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("connected".toConnectorStatus == ConnectorStatus.connected);
    assert("disconnected".toConnectorStatus == ConnectorStatus.disconnected);
    assert("error".toConnectorStatus == ConnectorStatus.error);

    assert("".toConnectorStatus == ConnectorStatus.connected);
    assert("unknown".toConnectorStatus == ConnectorStatus.connected);

    assert(["connected", "disconnected"].toConnectorStatuses == [
            ConnectorStatus.connected, ConnectorStatus.disconnected
        ]);

    assert(ConnectorStatus.connected.toString == "connected");
    assert(ConnectorStatus.disconnected.toString == "disconnected");
    assert(ConnectorStatus.error.toString == "error");

    assert([ConnectorStatus.connected, ConnectorStatus.disconnected].toStrings == [
            "connected", "disconnected"
        ]);
}

enum BackupStatus {
    pending,
    inProgress,
    completed,
    failed
}

BackupStatus toBackupStatus(string value) {
    mixin(EnumSwitch("BackupStatus", "pending"));
}

BackupStatus[] toBackupStatuses(string[] values) {
    return values.map!(toBackupStatus).array;
}

string toString(BackupStatus status) {
    return status.to!string;
}

string[] toStrings(BackupStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert("pending".toBackupStatus == BackupStatus.pending);
    assert("inProgress".toBackupStatus == BackupStatus.inProgress);
    assert("completed".toBackupStatus == BackupStatus.completed);
    assert("failed".toBackupStatus == BackupStatus.failed);

    assert("".toBackupStatus == BackupStatus.pending);
    assert("unknown".toBackupStatus == BackupStatus.pending);

    assert(["pending", "inProgress"].toBackupStatuses == [
            BackupStatus.pending, BackupStatus.inProgress
        ]);

    assert(BackupStatus.pending.toString == "pending");
    assert(BackupStatus.inProgress.toString == "inProgress");
    assert(BackupStatus.completed.toString == "completed");
    assert(BackupStatus.failed.toString == "failed");

    assert([BackupStatus.pending, BackupStatus.inProgress].toStrings == [
            "pending", "inProgress"
        ]);
}
