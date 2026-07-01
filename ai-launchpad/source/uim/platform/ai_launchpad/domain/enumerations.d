/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.enumerations;

import uim.platform.ai_launchpad;

// mixin(ShowModule!());

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
ConnectionStatus[] toConnectionStatus(string[] values) {
  return values.map!(v => toConnectionStatus(v)).array;
}
string toString(ConnectionStatus status) {
  return status.to!string;
}
string[] toString(ConnectionStatus[] statuses) {
  return statuses.map!(s => toString(s)).array;
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

  assert(toConnectionStatus(["active", "error", "unknown"]) == [ConnectionStatus.active, ConnectionStatus.error, ConnectionStatus.inactive]);
  assert(toString([ConnectionStatus.active, ConnectionStatus.error]) == ["active", "error"]);
}

enum ConnectionType {
  ai_core,
  custom
}
ConnectionType toConnectionType(string value) {
  mixin(EnumSwitch("ConnectionType", "custom"));
}
ConnectionType[] toConnectionType(string[] types) {
  return types.map!(toConnectionType).array;
}
string toString(ConnectionType type) {
  return type.to!string;
}
string[] toString(ConnectionType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("ConnectionType enum conversion"));

  assert(toConnectionType("ai_core") == ConnectionType.ai_core);
  assert(toConnectionType("custom") == ConnectionType.custom);
  assert(toConnectionType("unknown") == ConnectionType.custom); // default case 

  assert(toString(ConnectionType.ai_core) == "ai_core");
  assert(toString(ConnectionType.custom) == "custom");  

  assert(toConnectionType(["ai_core", "custom", "unknown"]) == [ConnectionType.ai_core, ConnectionType.custom, ConnectionType.custom]);
  assert(toString([ConnectionType.ai_core, ConnectionType.custom]) == ["ai_core", "custom"]);
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
ExecutionStatus[] toExecutionStatus(string[] values) {
  return values.map!(toExecutionStatus).array;
}
string toString(ExecutionStatus status) {
  return status.to!string;
}
string[] toString(ExecutionStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("ExecutionStatus enum conversion"));

  assert(toExecutionStatus("pending") == ExecutionStatus.pending);
  assert(toExecutionStatus("running") == ExecutionStatus.running);
  assert(toExecutionStatus("completed") == ExecutionStatus.completed);
  assert(toExecutionStatus("failed") == ExecutionStatus.failed);
  assert(toExecutionStatus("stopped") == ExecutionStatus.stopped);
  assert(toExecutionStatus("dead") == ExecutionStatus.dead);
  assert(toExecutionStatus("unknown") == ExecutionStatus.unknown); // default case
  assert(toExecutionStatus("thing") == ExecutionStatus.unknown); // default case

  assert(toString(ExecutionStatus.pending) == "pending");
  assert(toString(ExecutionStatus.running) == "running");
  assert(toString(ExecutionStatus.completed) == "completed");
  assert(toString(ExecutionStatus.failed) == "failed");
  assert(toString(ExecutionStatus.stopped) == "stopped");
  assert(toString(ExecutionStatus.dead) == "dead");
  assert(toString(ExecutionStatus.unknown) == "unknown");

  assert(toExecutionStatus(["pending", "running", "unknown"]) == [ExecutionStatus.pending, ExecutionStatus.running, ExecutionStatus.unknown]);
  assert(toString([ExecutionStatus.pending, ExecutionStatus.failed]) == ["pending", "failed"]);
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
DeploymentStatus[] toDeploymentStatus(string[] values) {
  return values.map!(toDeploymentStatus).array;
}
string toString(DeploymentStatus status) {
  return status.to!string;
}
string[] toString(DeploymentStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("DeploymentStatus enum conversion"));

  assert(toDeploymentStatus("pending") == DeploymentStatus.pending);
  assert(toDeploymentStatus("running") == DeploymentStatus.running);
  assert(toDeploymentStatus("stopped") == DeploymentStatus.stopped);
  assert(toDeploymentStatus("dead") == DeploymentStatus.dead);
  assert(toDeploymentStatus("unknown") == DeploymentStatus.unknown); 
  assert(toDeploymentStatus("thing") == DeploymentStatus.unknown); // default case

  assert(toString(DeploymentStatus.pending) == "pending");
  assert(toString(DeploymentStatus.running) == "running");
  assert(toString(DeploymentStatus.stopped) == "stopped");
  assert(toString(DeploymentStatus.dead) == "dead");
  assert(toString(DeploymentStatus.unknown) == "unknown");  

  assert(toDeploymentStatus(["pending", "running", "unknown"]) == [DeploymentStatus.pending, DeploymentStatus.running, DeploymentStatus.unknown]);
  assert(toString([DeploymentStatus.pending, DeploymentStatus.stopped]) == ["pending", "stopped"]);
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
ModelStatus[] toModelStatus(string[] values) {
  return values.map!(toModelStatus).array;
}
string toString(ModelStatus status) {
  return cast(string) status;
}
string[] toString(ModelStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("ModelStatus enum conversion"));

  assert(toModelStatus("available") == ModelStatus.available);
  assert(toModelStatus("archived") == ModelStatus.archived);
  assert(toModelStatus("deprecated") == ModelStatus.deprecated_);
  assert(toModelStatus("unknown") == ModelStatus.available); // default case    

  assert(toString(ModelStatus.available) == "available");
  assert(toString(ModelStatus.archived) == "archived");
  assert(toString(ModelStatus.deprecated_) == "deprecated");

  assert(toModelStatus(["available", "archived", "unknown"]) == [ModelStatus.available, ModelStatus.archived, ModelStatus.available]);
  assert(toString([ModelStatus.available, ModelStatus.deprecated_]) == ["available", "deprecated"]);
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
DatasetStatus[] toDatasetStatus(string[] values) {
  return values.map!(toDatasetStatus).array;
}
string toString(DatasetStatus status) {
  return status.to!string;
}
string[] toString(DatasetStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("DatasetStatus enum conversion"));

  assert(toDatasetStatus("available") == DatasetStatus.available);
  assert(toDatasetStatus("processing") == DatasetStatus.processing);
  assert(toDatasetStatus("error") == DatasetStatus.error);
  assert(toDatasetStatus("archived") == DatasetStatus.archived);
  assert(toDatasetStatus("unknown") == DatasetStatus.available); // default case

  assert(toString(DatasetStatus.available) == "available");
  assert(toString(DatasetStatus.processing) == "processing");
  assert(toString(DatasetStatus.error) == "error");
  assert(toString(DatasetStatus.archived) == "archived");

  assert(toDatasetStatus(["available", "error", "unknown"]) == [DatasetStatus.available, DatasetStatus.error, DatasetStatus.available]);
  assert(toString([DatasetStatus.available, DatasetStatus.archived]) == ["available", "archived"]);
}

// Workspace
enum WorkspaceStatus {
  active,
  inactive
}
WorkspaceStatus toWorkspaceStatus(string value) {
  mixin(EnumSwitch("WorkspaceStatus", "inactive"));
}
WorkspaceStatus[] toWorkspaceStatus(string[] values) {
  return values.map!(toWorkspaceStatus).array;
}
string toString(WorkspaceStatus status) {
  return status.to!string;
}
string[] toString(WorkspaceStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("WorkspaceStatus enum conversion"));

  assert(toWorkspaceStatus("active") == WorkspaceStatus.active);
  assert(toWorkspaceStatus("inactive") == WorkspaceStatus.inactive);
  assert(toWorkspaceStatus("unknown") == WorkspaceStatus.inactive); // default case

  assert(toString(WorkspaceStatus.active) == "active");
  assert(toString(WorkspaceStatus.inactive) == "inactive");

  assert(toWorkspaceStatus(["active", "unknown"]) == [WorkspaceStatus.active, WorkspaceStatus.inactive]);
  assert(toString([WorkspaceStatus.active, WorkspaceStatus.inactive]) == ["active", "inactive"]);
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
PromptRole[] toPromptRole(string[] roles) {
  return roles.map!(toPromptRole).array;
}
string toString(PromptRole role) {  return role.to!string;
}
string[] toString(PromptRole[] roles) {
  return roles.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("PromptRole enum conversion"));

  assert(toPromptRole("system") == PromptRole.system);
  assert(toPromptRole("user") == PromptRole.user);
  assert(toPromptRole("assistant") == PromptRole.assistant);
  assert(toPromptRole("unknown") == PromptRole.user); // default case 

  assert(toString(PromptRole.system) == "system");
  assert(toString(PromptRole.user) == "user");
  assert(toString(PromptRole.assistant) == "assistant");  

  assert(toPromptRole(["system", "assistant", "unknown"]) == [PromptRole.system, PromptRole.assistant, PromptRole.user]);
  assert(toString([PromptRole.system, PromptRole.assistant]) == ["system", "assistant"]);
}

enum PromptStatus {
  draft,
  active,
  archived
}
PromptStatus toPromptStatus(string value) {
  mixin(EnumSwitch("PromptStatus", "draft"));
}
PromptStatus[] toPromptStatus(string[] values) {
  return values.map!(toPromptStatus).array;
}
string toString(PromptStatus status) {
  return status.to!string;
}
string[] toString(PromptStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("PromptStatus enum conversion"));

  assert(toPromptStatus("draft") == PromptStatus.draft);
  assert(toPromptStatus("active") == PromptStatus.active);
  assert(toPromptStatus("archived") == PromptStatus.archived);
  assert(toPromptStatus("unknown") == PromptStatus.draft); // default case

  assert(toString(PromptStatus.draft) == "draft");
  assert(toString(PromptStatus.active) == "active");
  assert(toString(PromptStatus.archived) == "archived");  

  assert(toPromptStatus(["draft", "active", "unknown"]) == [PromptStatus.draft, PromptStatus.active, PromptStatus.draft]);
  assert(toString([PromptStatus.draft, PromptStatus.archived]) == ["draft", "archived"]);
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
ArtifactKind[] toArtifactKind(string[] kinds) {
  return kinds.map!(toArtifactKind).array;
}
string toString(ArtifactKind kind) {
  return kind.to!string;
}
string[] toString(ArtifactKind[] kinds) {
  return kinds.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("ArtifactKind enum conversion"));

  assert(toArtifactKind("model") == ArtifactKind.model);
  assert(toArtifactKind("dataset") == ArtifactKind.dataset);
  assert(toArtifactKind("resultset") == ArtifactKind.resultset);
  assert(toArtifactKind("unknown") == ArtifactKind.other); // default case

  assert(toString(ArtifactKind.model) == "model");
  assert(toString(ArtifactKind.dataset) == "dataset");
  assert(toString(ArtifactKind.resultset) == "resultset");
  assert(toString(ArtifactKind.other) == "other");

  assert(toArtifactKind(["model", "resultset", "unknown"]) == [ArtifactKind.model, ArtifactKind.resultset, ArtifactKind.other]);
  assert(toString([ArtifactKind.model, ArtifactKind.dataset]) == ["model", "dataset"]);
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
TargetStatus[] toTargetStatus(string[] values) {
  return values.map!(toTargetStatus).array;
}
string toString(TargetStatus status) {
  return status.to!string;
}
string[] toString(TargetStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("TargetStatus enum conversion")); 

  assert(toTargetStatus("running") == TargetStatus.running);
  assert(toTargetStatus("stopped") == TargetStatus.stopped);
  assert(toTargetStatus("deleted") == TargetStatus.deleted_);
  assert(toTargetStatus("completed") == TargetStatus.completed);
  assert(toTargetStatus("unknown") == TargetStatus.stopped); // default case

  assert(toString(TargetStatus.running) == "running");
  assert(toString(TargetStatus.stopped) == "stopped");
  assert(toString(TargetStatus.deleted_) == "deleted"); 
  assert(toString(TargetStatus.completed) == "completed");

  assert(toTargetStatus(["running", "deleted", "unknown"]) == [TargetStatus.running, TargetStatus.deleted_, TargetStatus.stopped]);
  assert(toString([TargetStatus.running, TargetStatus.completed]) == ["running", "completed"]);
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
MetricValueType[] toMetricValueType(string[] values) {
  return values.map!(toMetricValueType).array;
}
string toString(MetricValueType type) {
  return cast(string)type;
}
string[] toString(MetricValueType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("MetricValueType enum conversion"));

  assert(toMetricValueType("float") == MetricValueType.float_);
  assert(toMetricValueType("int") == MetricValueType.int_);
  assert(toMetricValueType("string") == MetricValueType.string_);
  assert(toMetricValueType("unknown") == MetricValueType.string_); // default case

  assert(toString(MetricValueType.float_) == "float");
  assert(toString(MetricValueType.int_) == "int");
  assert(toString(MetricValueType.string_) == "string");

  assert(toMetricValueType(["float", "int", "unknown"]) == [MetricValueType.float_, MetricValueType.int_, MetricValueType.string_]);
  assert(toString([MetricValueType.float_, MetricValueType.string_]) == ["float", "string"]);
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
StatisticsPeriod[] toStatisticsPeriod(string[] values) {
  return values.map!(toStatisticsPeriod).array;
}
string toString(StatisticsPeriod period) {
  return period.to!string;
}
string[] toString(StatisticsPeriod[] periods) {
  return periods.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("StatisticsPeriod enum conversion"));   

  assert(toStatisticsPeriod("daily") == StatisticsPeriod.daily);
  assert(toStatisticsPeriod("weekly") == StatisticsPeriod.weekly);
  assert(toStatisticsPeriod("monthly") == StatisticsPeriod.monthly);
  assert(toStatisticsPeriod("unknown") == StatisticsPeriod.daily); // default case

  assert(toString(StatisticsPeriod.daily) == "daily");
  assert(toString(StatisticsPeriod.weekly) == "weekly");
  assert(toString(StatisticsPeriod.monthly) == "monthly");

  assert(toStatisticsPeriod(["daily", "weekly", "unknown"]) == [StatisticsPeriod.daily, StatisticsPeriod.weekly, StatisticsPeriod.daily]);
  assert(toString([StatisticsPeriod.daily, StatisticsPeriod.monthly]) == ["daily", "monthly"]);
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
LogSeverity[] toLogSeverity(string[] values) {
  return values.map!(toLogSeverity).array;
}
string toString(LogSeverity severity) {
  return severity.to!string;
}
string[] toString(LogSeverity[] severities) {
  return severities.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("LogSeverity enum conversion"));

  assert(toLogSeverity("info") == LogSeverity.info);
  assert(toLogSeverity("warn") == LogSeverity.warn);
  assert(toLogSeverity("error") == LogSeverity.error);
  assert(toLogSeverity("unknown") == LogSeverity.info); // default case 

  assert(toString(LogSeverity.info) == "info");
  assert(toString(LogSeverity.warn) == "warn");
  assert(toString(LogSeverity.error) == "error");

  assert(toLogSeverity(["info", "error", "unknown"]) == [LogSeverity.info, LogSeverity.error, LogSeverity.info]);
  assert(toString([LogSeverity.info, LogSeverity.warn]) == ["info", "warn"]);
}

// Schedule status
enum ScheduleStatus {
  active,
  inactive
}
ScheduleStatus toScheduleStatus(string value) {
  mixin(EnumSwitch("ScheduleStatus", "inactive"));
}
ScheduleStatus[] toScheduleStatus(string[] values) {
  return values.map!(toScheduleStatus).array;
}
string toString(ScheduleStatus status) {
  return status.to!string;
}
string[] toString(ScheduleStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  mixin(ShowTest!("ScheduleStatus enum conversion"));

  assert(toScheduleStatus("active") == ScheduleStatus.active);
  assert(toScheduleStatus("inactive") == ScheduleStatus.inactive);
  assert(toScheduleStatus("unknown") == ScheduleStatus.inactive); // default case

  assert(toString(ScheduleStatus.active) == "active");
  assert(toString(ScheduleStatus.inactive) == "inactive");

  assert(toScheduleStatus(["active", "unknown"]) == [ScheduleStatus.active, ScheduleStatus.inactive]);
  assert(toString([ScheduleStatus.active, ScheduleStatus.inactive]) == ["active", "inactive"]);
}