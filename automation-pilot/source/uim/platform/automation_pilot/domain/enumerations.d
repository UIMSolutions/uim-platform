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

    assert(toString([CatalogType.system, CatalogType.custom]) == [
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

    assert(toString([
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
    assert(toCommandStatus("active") == CommandStatus.active);
    assert(toCommandStatus("inactive") == CommandStatus.inactive);
    assert(toCommandStatus("draft") == CommandStatus.draft);
    assert(toCommandStatus("deprecated") == CommandStatus.deprecated_);

    assert(toCommandStatus("") == CommandStatus.active);
    assert(toCommandStatus("unknown") == CommandStatus.active);

    assert(toCommandStatus(["active", "inactive", "deprecated", "unknown"]) == [
            CommandStatus.active, CommandStatus.inactive,
            CommandStatus.deprecated_,
            CommandStatus.active
        ]);

    assert(toString(CommandStatus.active) == "active");
    assert(toString(CommandStatus.inactive) == "inactive");
    assert(toString(CommandStatus.deprecated_) == "deprecated");

    assert(toString([
            CommandStatus.active, CommandStatus.inactive,
            CommandStatus.deprecated_
        ]) == ["active", "inactive", "deprecated"]);
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
    assert(toCommandType("simple") == CommandType.simple);
    assert(toCommandType("composite") == CommandType.composite);
    assert(toCommandType("httpRequest") == CommandType.httpRequest);
    assert(toCommandType("script") == CommandType.script);

    assert(toCommandType("") == CommandType.simple);
    assert(toCommandType("unknown") == CommandType.simple);

    assert(toCommandTypes([
            "simple", "composite", "httpRequest", "script", "unknown"
        ]) == [
        CommandType.simple, CommandType.composite, CommandType.httpRequest,
        CommandType.script, CommandType.simple
    ]);

    assert(toString(CommandType.simple) == "simple");
    assert(toString(CommandType.composite) == "composite");
    assert(toString(CommandType.httpRequest) == "httpRequest");
    assert(toString(CommandType.script) == "script");

    assert(toString([
            CommandType.simple, CommandType.composite, CommandType.httpRequest,
            CommandType.script
        ]) == ["simple", "composite", "httpRequest", "script"]);
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
    return s.map!(toExecutionStatus).array;
}

string toString(ExecutionStatus status) {
    return status.to!string;
}

string[] toStrings(ExecutionStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    assert(toExecutionStatus("pending") == ExecutionStatus.pending);
    assert(toExecutionStatus("running") == ExecutionStatus.running);
    assert(toExecutionStatus("completed") == ExecutionStatus.completed);
    assert(toExecutionStatus("failed") == ExecutionStatus.failed);
    assert(toExecutionStatus("cancelled") == ExecutionStatus.cancelled);
    assert(toExecutionStatus("timedOut") == ExecutionStatus.timedOut);

    assert(toExecutionStatus("") == ExecutionStatus.pending);
    assert(toExecutionStatus("unknown") == ExecutionStatus.pending);

    assert(toExecutionStatuses([
            "pending", "running", "completed", "failed", "cancelled", "timedOut",
            "unknown"
        ]) == [
        ExecutionStatus.pending, ExecutionStatus.running,
        ExecutionStatus.completed, ExecutionStatus.failed,
        ExecutionStatus.cancelled, ExecutionStatus.timedOut,
        ExecutionStatus.pending
    ]);

    assert(toString(ExecutionStatus.pending) == "pending");
    assert(toString(ExecutionStatus.running) == "running");
    assert(toString(ExecutionStatus.completed) == "completed");
    assert(toString(ExecutionStatus.failed) == "failed");
    assert(toString(ExecutionStatus.cancelled) == "cancelled");
    assert(toString(ExecutionStatus.timedOut) == "timedOut");

    assert(toString([
            ExecutionStatus.pending, ExecutionStatus.running,
            ExecutionStatus.completed, ExecutionStatus.failed,
            ExecutionStatus.cancelled, ExecutionStatus.timedOut
        ]) == [
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
    assert(toExecutionPriority("low") == ExecutionPriority.low);
    assert(toExecutionPriority("medium") == ExecutionPriority.medium);
    assert(toExecutionPriority("high") == ExecutionPriority.high);
    assert(toExecutionPriority("critical") == ExecutionPriority.critical);

    assert(toExecutionPriority("") == ExecutionPriority.medium);
    assert(toExecutionPriority("unknown") == ExecutionPriority.medium);

    assert(toExecutionPriorities([
            "low", "medium", "high", "critical", "unknown"
        ]) == [
        ExecutionPriority.low, ExecutionPriority.medium, ExecutionPriority.high,
        ExecutionPriority.critical, ExecutionPriority.medium
    ]);

    assert(toString(ExecutionPriority.low) == "low");
    assert(toString(ExecutionPriority.medium) == "medium");
    assert(toString(ExecutionPriority.high) == "high");
    assert(toString(ExecutionPriority.critical) == "critical");

    assert(toString([
            ExecutionPriority.low, ExecutionPriority.medium,
            ExecutionPriority.high, ExecutionPriority.critical
        ]) == ["low", "medium", "high", "critical"]);
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
    assert(toScheduleType("oneTime") == ScheduleType.oneTime);
    assert(toScheduleType("recurring") == ScheduleType.recurring);
    assert(toScheduleType("cron") == ScheduleType.cron);

    assert(toScheduleType("") == ScheduleType.oneTime);
    assert(toScheduleType("unknown") == ScheduleType.oneTime);

    assert(toScheduleTypes(["oneTime", "recurring", "cron", "unknown"]) == [
            ScheduleType.oneTime, ScheduleType.recurring, ScheduleType.cron,
            ScheduleType.oneTime
        ]);

    assert(toString(ScheduleType.oneTime) == "oneTime");
    assert(toString(ScheduleType.recurring) == "recurring");
    assert(toString(ScheduleType.cron) == "cron");

    assert(toString([
            ScheduleType.oneTime, ScheduleType.recurring, ScheduleType.cron
        ]) == ["oneTime", "recurring", "cron"]);
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
    assert(toScheduleStatus("active") == ScheduleStatus.active);
    assert(toScheduleStatus("paused") == ScheduleStatus.paused);
    assert(toScheduleStatus("completed") == ScheduleStatus.completed);
    assert(toScheduleStatus("expired") == ScheduleStatus.expired);

    assert(toScheduleStatus("") == ScheduleStatus.active);
    assert(toScheduleStatus("unknown") == ScheduleStatus.active);

    assert(toScheduleStatuses([
            "active", "paused", "completed", "expired", "unknown"
        ]) == [
        ScheduleStatus.active, ScheduleStatus.paused, ScheduleStatus.completed,
        ScheduleStatus.expired, ScheduleStatus.active
    ]);

    assert(toString(ScheduleStatus.active) == "active");
    assert(toString(ScheduleStatus.paused) == "paused");
    assert(toString(ScheduleStatus.completed) == "completed");
    assert(toString(ScheduleStatus.expired) == "expired");

    assert(toString([
            ScheduleStatus.active, ScheduleStatus.paused, ScheduleStatus.completed,
            ScheduleStatus.expired
        ]) == ["active", "paused", "completed", "expired"]);
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
    assert(toTriggerStatus("active") == TriggerStatus.active);
    assert(toTriggerStatus("inactive") == TriggerStatus.inactive);
    assert(toTriggerStatus("disabled") == TriggerStatus.disabled);

    assert(toTriggerStatus("") == TriggerStatus.active);
    assert(toTriggerStatus("unknown") == TriggerStatus.active);

    assert(toTriggerStatuses(["active", "inactive", "disabled", "unknown"]) == [
            TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.disabled,
            TriggerStatus.active
        ]);

    assert(toString(TriggerStatus.active) == "active");
    assert(toString(TriggerStatus.inactive) == "inactive");
    assert(toString(TriggerStatus.disabled) == "disabled");

    assert(toString([
            TriggerStatus.active, TriggerStatus.inactive, TriggerStatus.disabled
        ]) == ["active", "inactive", "disabled"]);
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
    assert(toInputSensitivity("normal") == InputSensitivity.normal);
    assert(toInputSensitivity("sensitive") == InputSensitivity.sensitive);
    assert(toInputSensitivity("secret") == InputSensitivity.secret);

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
    assert(toServiceAccountStatus("active") == ServiceAccountStatus.active);
    assert(toServiceAccountStatus("inactive") == ServiceAccountStatus.inactive);
    assert(toServiceAccountStatus("revoked") == ServiceAccountStatus.revoked);

    assert("".toServiceAccountStatus == ServiceAccountStatus.active);
    assert("unknown".toServiceAccountStatus == ServiceAccountStatus.active);

    assert(["active", "inactive"].toServiceAccountStatus == [
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
    assert(toConnectorType("github") == ConnectorType.github);
    assert(toConnectorType("gitLab") == ConnectorType.gitLab);
    assert(toConnectorType("bitbucket") == ConnectorType.bitbucket);
    assert(toConnectorType("s3") == ConnectorType.s3);

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
    assert(toConnectorStatus("connected") == ConnectorStatus.connected);
    assert(toConnectorStatus("disconnected") == ConnectorStatus.disconnected);
    assert(toConnectorStatus("error") == ConnectorStatus.error);

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
    assert(toBackupStatus("pending") == BackupStatus.pending);
    assert(toBackupStatus("inProgress") == BackupStatus.inProgress);
    assert(toBackupStatus("completed") == BackupStatus.completed);
    assert(toBackupStatus("failed") == BackupStatus.failed);

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
