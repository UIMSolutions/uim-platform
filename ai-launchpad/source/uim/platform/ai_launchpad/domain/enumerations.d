/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.enumerations;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

// Connection to an AI runtime instance
enum ConnectionStatus {
  active,
  inactive,
  error,
  pending
}
ConnectionStatus toConnectionStatus(string value) {
  mixin(EnumSwitch("ConnectionStatus", "inactive"));
}
ConnectionStatus[] toConnectionStatuses(string[] values) {
  return values.map!toConnectionStatus.array;
}
string toString(ConnectionStatus status) {
  return status.to!string;
}
string[] toStrings(ConnectionStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ConnectionStatus enum conversion"));

  assert("active".toConnectionStatus == ConnectionStatus.active);
  assert("inactive".toConnectionStatus == ConnectionStatus.inactive);
  assert("error".toConnectionStatus == ConnectionStatus.error);
  assert("pending".toConnectionStatus == ConnectionStatus.pending);
  assert("unknown".toConnectionStatus == ConnectionStatus.inactive); // default case

  assert(ConnectionStatus.active.toString == "active");
  assert(ConnectionStatus.inactive.toString == "inactive");
  assert(ConnectionStatus.error.toString == "error");
  assert(ConnectionStatus.pending.toString == "pending");

  assert(["active", "error", "unknown"].toConnectionStatuses == [ConnectionStatus.active, ConnectionStatus.error, ConnectionStatus.inactive]);
  assert([ConnectionStatus.active, ConnectionStatus.error].toStrings == ["active", "error"]);
}

enum ConnectionType {
  ai_core,
  custom
}
ConnectionType toConnectionType(string value) {
  mixin(EnumSwitch("ConnectionType", "custom"));
}
ConnectionType[] toConnectionTypes(string[] types) {
  return types.map!toConnectionType.array;
}
string toString(ConnectionType type) {
  return type.to!string;
}
string[] toStrings(ConnectionType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ConnectionType enum conversion"));

  assert("ai_core".toConnectionType == ConnectionType.ai_core);
  assert("custom".toConnectionType == ConnectionType.custom);

  assert("".toConnectionType == ConnectionType.custom); // default case 
  assert("unknown".toConnectionType == ConnectionType.custom); // default case 

  assert(ConnectionType.ai_core.toString == "ai_core");
  assert(ConnectionType.custom.toString == "custom");  

  assert(["ai_core", "custom", "unknown"].toConnectionTypes == [ConnectionType.ai_core, ConnectionType.custom, ConnectionType.custom]);
  assert([ConnectionType.ai_core, ConnectionType.custom].toStrings == ["ai_core", "custom"]);
}

// Execution lifecycle
enum ExecutionStatus {
  unknown,
  pending,
  running,
  completed,
  failed,
  stopped,
  dead
}
ExecutionStatus toExecutionStatus(string value) {
  mixin(EnumSwitch("ExecutionStatus", "unknown"));
}
ExecutionStatus[] toExecutionStatuses(string[] values) {
  return values.map!toExecutionStatus.array;
}
string toString(ExecutionStatus status) {
  return status.to!string;
}
string[] toStrings(ExecutionStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ExecutionStatus enum conversion"));

  assert("pending".toExecutionStatus == ExecutionStatus.pending);
  assert("running".toExecutionStatus == ExecutionStatus.running);
  assert("completed".toExecutionStatus == ExecutionStatus.completed);
  assert("failed".toExecutionStatus == ExecutionStatus.failed);
  assert("stopped".toExecutionStatus == ExecutionStatus.stopped);
  assert("dead".toExecutionStatus == ExecutionStatus.dead);
  assert("unknown".toExecutionStatus == ExecutionStatus.unknown); // default case
  assert("thing".toExecutionStatus == ExecutionStatus.unknown); // default case

  assert(ExecutionStatus.pending.toString == "pending");
  assert(ExecutionStatus.running.toString == "running");
  assert(ExecutionStatus.completed.toString == "completed");
  assert(ExecutionStatus.failed.toString == "failed");
  assert(ExecutionStatus.stopped.toString == "stopped");
  assert(ExecutionStatus.dead.toString == "dead");
  assert(ExecutionStatus.unknown.toString == "unknown");

  assert(["pending", "running", "unknown"].toExecutionStatuses == [ExecutionStatus.pending, ExecutionStatus.running, ExecutionStatus.unknown]);
  assert([ExecutionStatus.pending, ExecutionStatus.failed].toStrings == ["pending", "failed"]);
}

// Deployment lifecycle
enum DeploymentStatus {
  pending,
  running,
  stopped,
  dead,
  unknown
}
DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "unknown"));
}
DeploymentStatus[] toDeploymentStatuses(string[] values) {
  return values.map!toDeploymentStatus.array;
}
string toString(DeploymentStatus status) {
  return status.to!string;
}
string[] toStrings(DeploymentStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DeploymentStatus enum conversion"));

  assert("pending".toDeploymentStatus == DeploymentStatus.pending);
  assert("running".toDeploymentStatus == DeploymentStatus.running);
  assert("stopped".toDeploymentStatus == DeploymentStatus.stopped);
  assert("dead".toDeploymentStatus == DeploymentStatus.dead);
  assert("unknown".toDeploymentStatus == DeploymentStatus.unknown); 

  assert("".toDeploymentStatus == DeploymentStatus.unknown); // default case
  assert("something".toDeploymentStatus == DeploymentStatus.unknown); // default case

  assert(DeploymentStatus.pending.toString == "pending");
  assert(DeploymentStatus.running.toString == "running");
  assert(DeploymentStatus.stopped.toString == "stopped");
  assert(DeploymentStatus.dead.toString == "dead");
  assert(DeploymentStatus.unknown.toString == "unknown");

  assert(["pending", "running", "unknown"].toDeploymentStatuses == [DeploymentStatus.pending, DeploymentStatus.running, DeploymentStatus.unknown]);
  assert([DeploymentStatus.pending, DeploymentStatus.stopped].toStrings == ["pending", "stopped"]);
}

// Model tracking
enum ModelStatus {
  available = "available",
  archived = "archived",
  deprecated_ = "deprecated"
}
ModelStatus toModelStatus(string value) {
  switch (value.toLower) {
    case "available": return ModelStatus.available;
    case "archived": return ModelStatus.archived;
    case "deprecated": return ModelStatus.deprecated_;
    default: return ModelStatus.available; // default to available if unknown
  }
}
ModelStatus[] toModelStatuses(string[] values) {
  return values.map!toModelStatus.array;
}
string toString(ModelStatus status) {
  return cast(string) status;
}
string[] toStrings(ModelStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ModelStatus enum conversion"));

  assert("available".toModelStatus == ModelStatus.available);
  assert("archived".toModelStatus == ModelStatus.archived);
  assert("deprecated".toModelStatus == ModelStatus.deprecated_);
  assert("unknown".toModelStatus == ModelStatus.available); // default case    

  assert(ModelStatus.available.toString == "available");
  assert(ModelStatus.archived.toString == "archived");
  assert(ModelStatus.deprecated_.toString == "deprecated");

  assert(["available", "archived", "unknown"].toModelStatuses == [ModelStatus.available, ModelStatus.archived, ModelStatus.available]);
  assert([ModelStatus.available, ModelStatus.deprecated_].toStrings == ["available", "deprecated"]);
}

// Dataset tracking
enum DatasetStatus {
  available,
  processing,
  error,
  archived
}
DatasetStatus toDatasetStatus(string value) {
  mixin(EnumSwitch("DatasetStatus", "available"));
}
DatasetStatus[] toDatasetStatuses(string[] values) {
  return values.map!toDatasetStatus.array;
}
string toString(DatasetStatus status) {
  return status.to!string;
}
string[] toStrings(DatasetStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DatasetStatus enum conversion"));

  assert("available".toDatasetStatus == DatasetStatus.available);
  assert("processing".toDatasetStatus == DatasetStatus.processing);
  assert("error".toDatasetStatus == DatasetStatus.error);
  assert("archived".toDatasetStatus == DatasetStatus.archived);
  assert("unknown".toDatasetStatus == DatasetStatus.available); // default case

  assert(DatasetStatus.available.toString == "available");
  assert(DatasetStatus.processing.toString == "processing");
  assert(DatasetStatus.error.toString == "error");
  assert(DatasetStatus.archived.toString == "archived");

  assert(["available", "error", "unknown"].toDatasetStatuses == [DatasetStatus.available, DatasetStatus.error, DatasetStatus.available]);
  assert([DatasetStatus.available, DatasetStatus.archived].toStrings == ["available", "archived"]);
}

// Workspace
enum WorkspaceStatus {
  active,
  inactive
}
WorkspaceStatus toWorkspaceStatus(string value) {
  mixin(EnumSwitch("WorkspaceStatus", "inactive"));
}
WorkspaceStatus[] toWorkspaceStatuses(string[] values) {
  return values.map!toWorkspaceStatus.array;
}
string toString(WorkspaceStatus status) {
  return status.to!string;
}
string[] toStrings(WorkspaceStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("WorkspaceStatus enum conversion"));

  assert("active".toWorkspaceStatus == WorkspaceStatus.active);
  assert("inactive".toWorkspaceStatus == WorkspaceStatus.inactive);
  assert("unknown".toWorkspaceStatus == WorkspaceStatus.inactive); // default case

  assert(WorkspaceStatus.active.toString == "active");
  assert(WorkspaceStatus.inactive.toString == "inactive");

  assert(["active", "unknown"].toWorkspaceStatuses == [WorkspaceStatus.active, WorkspaceStatus.inactive]);
  assert([WorkspaceStatus.active, WorkspaceStatus.inactive].toStrings == ["active", "inactive"]);
}

// GenAI Hub prompt management
enum PromptRole {
  system,
  user,
  assistant
}
PromptRole toPromptRole(string value) {
  mixin(EnumSwitch("PromptRole", "user"));
}
PromptRole[] toPromptRoles(string[] roles) {
  return roles.map!toPromptRole.array;
}
string toString(PromptRole role) {  return role.to!string;
}
string[] toStrings(PromptRole[] roles) {
  return roles.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PromptRole enum conversion"));

  assert("system".toPromptRole == PromptRole.system);
  assert("user".toPromptRole == PromptRole.user);
  assert("assistant".toPromptRole == PromptRole.assistant);
  assert("unknown".toPromptRole == PromptRole.user); // default case 

  assert(PromptRole.system.toString == "system");
  assert(PromptRole.user.toString == "user");
  assert(PromptRole.assistant.toString == "assistant");  

  assert(["system", "assistant", "unknown"].toPromptRoles == [PromptRole.system, PromptRole.assistant, PromptRole.user]);
  assert([PromptRole.system, PromptRole.assistant].toStrings == ["system", "assistant"]);
}

enum PromptStatus {
  draft,
  active,
  archived
}
PromptStatus toPromptStatus(string value) {
  mixin(EnumSwitch("PromptStatus", "draft"));
}
PromptStatus[] toPromptStatuses(string[] values) {
  return values.map!toPromptStatus.array;
}
string toString(PromptStatus status) {
  return status.to!string;
}
string[] toStrings(PromptStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PromptStatus enum conversion"));

  assert("draft".toPromptStatus == PromptStatus.draft);
  assert("active".toPromptStatus == PromptStatus.active);
  assert("archived".toPromptStatus == PromptStatus.archived);
  assert("unknown".toPromptStatus == PromptStatus.draft); // default case

  assert(PromptStatus.draft.toString == "draft");
  assert(PromptStatus.active.toString == "active");
  assert(PromptStatus.archived.toString == "archived");  

  assert(["draft", "active", "unknown"].toPromptStatuses == [PromptStatus.draft, PromptStatus.active, PromptStatus.draft]);
  assert([PromptStatus.draft, PromptStatus.archived].toStrings == ["draft", "archived"]);
}
 
// Artifact classification
enum ArtifactKind {
  model,
  dataset,
  resultset,
  other
}
ArtifactKind toArtifactKind(string value) {
  mixin(EnumSwitch("ArtifactKind", "other"));
}
ArtifactKind[] toArtifactKinds(string[] kinds) {
  return kinds.map!toArtifactKind.array;
}
string toString(ArtifactKind kind) {
  return kind.to!string;
}
string[] toStrings(ArtifactKind[] kinds) {
  return kinds.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ArtifactKind enum conversion"));

  assert("model".toArtifactKind == ArtifactKind.model);
  assert("dataset".toArtifactKind == ArtifactKind.dataset);
  assert("resultset".toArtifactKind == ArtifactKind.resultset);
  assert("unknown".toArtifactKind == ArtifactKind.other); // default case

  assert(ArtifactKind.model.toString == "model");
  assert(ArtifactKind.dataset.toString == "dataset");
  assert(ArtifactKind.resultset.toString == "resultset");
  assert(ArtifactKind.other.toString == "other");

  assert(["model", "resultset", "unknown"].toArtifactKinds == [ArtifactKind.model, ArtifactKind.resultset, ArtifactKind.other]);
  assert([ArtifactKind.model, ArtifactKind.dataset].toStrings == ["model", "dataset"]);
}

// Target status for lifecycle operations
enum TargetStatus {
  running,
  stopped,
  deleted,
  completed
}
TargetStatus toTargetStatus(string value) {
  switch (value.toLower) {
    case "running": return TargetStatus.running;
    case "stopped": return TargetStatus.stopped;
    case "deleted": return TargetStatus.deleted;
    case "completed": return TargetStatus.completed;
    default: return TargetStatus.stopped; // default to stopped if unknown
  }
}
TargetStatus[] toTargetStatuses(string[] values) {
  return values.map!toTargetStatus.array;
}
string toString(TargetStatus status) {
  return status.to!string;
}
string[] toStrings(TargetStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("TargetStatus enum conversion")); 

  assert("running".toTargetStatus == TargetStatus.running);
  assert("stopped".toTargetStatus == TargetStatus.stopped);
  assert("deleted".toTargetStatus == TargetStatus.deleted);
  assert("completed".toTargetStatus == TargetStatus.completed);
  assert("unknown".toTargetStatus == TargetStatus.stopped); // default case

  assert(TargetStatus.running.toString == "running");
  assert(TargetStatus.stopped.toString == "stopped");
  assert(TargetStatus.deleted.toString == "deleted");
  assert(TargetStatus.completed.toString == "completed");

  assert(["running", "deleted", "unknown"].toTargetStatuses == [TargetStatus.running, TargetStatus.deleted, TargetStatus.stopped]);
  assert([TargetStatus.running, TargetStatus.completed].toStrings == ["running", "completed"]);
}

// Metric value types
enum MetricValueType : string {
  float_ = "float",
  int_ = "int",
  string_ = "string"
}
MetricValueType toMetricValueType(string value) {
  switch (value.toLower) {
    case "float": return MetricValueType.float_;
    case "int": return MetricValueType.int_;
    case "string": return MetricValueType.string_;
    default: return MetricValueType.string_; // default to string if unknown
  }
}
MetricValueType[] toMetricValueTypes(string[] values) {
  return values.map!toMetricValueType.array;
}
string toString(MetricValueType type) {
  return cast(string)type;
}
string[] toStrings(MetricValueType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("MetricValueType enum conversion"));

  assert("float".toMetricValueType == MetricValueType.float_);
  assert("int".toMetricValueType == MetricValueType.int_);
  assert("string".toMetricValueType == MetricValueType.string_);

  assert("".toMetricValueType == MetricValueType.string_); // default case
  assert("unknown".toMetricValueType == MetricValueType.string_); // default case

  assert(MetricValueType.float_.toString == "float");
  assert(MetricValueType.int_.toString == "int");
  assert(MetricValueType.string_.toString == "string");

  assert(["float", "int", "unknown"].toMetricValueTypes == [MetricValueType.float_, MetricValueType.int_, MetricValueType.string_]);
  assert([MetricValueType.float_, MetricValueType.string_].toStrings == ["float", "string"]);
}

// Usage statistics
enum StatisticsPeriod {
  daily,
  weekly,
  monthly
}
StatisticsPeriod toStatisticsPeriod(string value) {
  mixin(EnumSwitch("StatisticsPeriod", "daily"));
}
StatisticsPeriod[] toStatisticsPeriods(string[] values) {
  return values.map!toStatisticsPeriod.array;
}
string toString(StatisticsPeriod period) {
  return period.to!string;
}
string[] toStrings(StatisticsPeriod[] periods) {
  return periods.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("StatisticsPeriod enum conversion"));   

  assert("daily".toStatisticsPeriod == StatisticsPeriod.daily);
  assert("weekly".toStatisticsPeriod == StatisticsPeriod.weekly);
  assert("monthly".toStatisticsPeriod == StatisticsPeriod.monthly);
  assert("unknown".toStatisticsPeriod == StatisticsPeriod.daily); // default case

  assert(StatisticsPeriod.daily.toString == "daily");
  assert(StatisticsPeriod.weekly.toString == "weekly");
  assert(StatisticsPeriod.monthly.toString == "monthly");

  assert(["daily", "weekly", "unknown"].toStatisticsPeriods == [StatisticsPeriod.daily, StatisticsPeriod.weekly, StatisticsPeriod.daily]);
  assert([StatisticsPeriod.daily, StatisticsPeriod.monthly].toStrings == ["daily", "monthly"]);
}

// Log severity levels
enum LogSeverity {
  info,
  warn,
  error
}
LogSeverity toLogSeverity(string value) {
  mixin(EnumSwitch("LogSeverity", "info"));
}
LogSeverity[] toLogSeverities(string[] values) {
  return values.map!toLogSeverity.array;
}
string toString(LogSeverity severity) {
  return severity.to!string;
}
string[] toStrings(LogSeverity[] severities) {
  return severities.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("LogSeverity enum conversion"));

  assert("info".toLogSeverity == LogSeverity.info);
  assert("warn".toLogSeverity == LogSeverity.warn);
  assert("error".toLogSeverity == LogSeverity.error);

  assert("".toLogSeverity == LogSeverity.info); // default case 
  assert("unknown".toLogSeverity == LogSeverity.info); // default case 

  assert(LogSeverity.info.toString == "info");
  assert(LogSeverity.warn.toString == "warn");
  assert(LogSeverity.error.toString == "error");

  assert(["info", "error", "unknown"].toLogSeverities == [LogSeverity.info, LogSeverity.error, LogSeverity.info]);
  assert([LogSeverity.info, LogSeverity.warn].toStrings == ["info", "warn"]);
}

// Schedule status
enum ScheduleStatus {
  active,
  inactive
}
ScheduleStatus toScheduleStatus(string value) {
  mixin(EnumSwitch("ScheduleStatus", "inactive"));
}
ScheduleStatus[] toScheduleStatuses(string[] values) {
  return values.map!toScheduleStatus.array;
}
string toString(ScheduleStatus status) {
  return status.to!string;
}
string[] toStrings(ScheduleStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ScheduleStatus enum conversion"));

  assert("active".toScheduleStatus == ScheduleStatus.active);
  assert("inactive".toScheduleStatus == ScheduleStatus.inactive);

  assert("".toScheduleStatus == ScheduleStatus.inactive); // default case
  assert("unknown".toScheduleStatus == ScheduleStatus.inactive); // default case

  assert(ScheduleStatus.active.toString == "active");
  assert(ScheduleStatus.inactive.toString == "inactive");

  assert(["active", "unknown"].toScheduleStatuses == [ScheduleStatus.active, ScheduleStatus.inactive]);
  assert([ScheduleStatus.active, ScheduleStatus.inactive].toStrings == ["active", "inactive"]);
}