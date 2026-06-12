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
ConnectionStatus toConnectionStatus(string status) {
  const map = [
    "active": ConnectionStatus.active,
    "inactive": ConnectionStatus.inactive,
    "error": ConnectionStatus.error,
    "pending": ConnectionStatus.pending
  ];
  return map.get(status.toLower, ConnectionStatus.inactive);
}

enum ConnectionType {
  ai_core,
  custom
}
ConnectionType toConnectionType(string type) {
  const map = [
    "ai_core": ConnectionType.ai_core,
    "custom": ConnectionType.custom
  ];
  return map.get(type.toLower, ConnectionType.custom);
}

// Execution lifecycle
enum ExecutionStatus {
  pending,
  running,
  completed,
  failed,
  stopped,
  dead,
  unknown
}
ExecutionStatus toExecutionStatus(string status) {
  const map = [
    "pending": ExecutionStatus.pending,
    "running": ExecutionStatus.running,
    "completed": ExecutionStatus.completed,
    "failed": ExecutionStatus.failed,
    "stopped": ExecutionStatus.stopped,
    "dead": ExecutionStatus.dead,
    "unknown": ExecutionStatus.unknown
  ];
  return map.get(status.toLower, ExecutionStatus.unknown);
}

// Deployment lifecycle
enum DeploymentStatus {
  pending,
  running,
  stopped,
  dead,
  unknown
}
DeploymentStatus toDeploymentStatus(string status) {
  const map = [
    "pending": DeploymentStatus.pending,
    "running": DeploymentStatus.running,
    "stopped": DeploymentStatus.stopped,
    "dead": DeploymentStatus.dead,
    "unknown": DeploymentStatus.unknown
  ];
  return map.get(status.toLower, DeploymentStatus.unknown);
} 

// Model tracking
enum ModelStatus {
  available,
  archived,
  deprecated_
}
ModelStatus toModelStatus(string status) {
  const map = [
    "available": ModelStatus.available,
    "archived": ModelStatus.archived,
    "deprecated": ModelStatus.deprecated_
  ];
  return map.get(status.toLower, ModelStatus.available);
}

// Dataset tracking
enum DatasetStatus {
  available,
  processing,
  error,
  archived
}
DatasetStatus toDatasetStatus(string status) {
  const map = [
    "available": DatasetStatus.available,
    "processing": DatasetStatus.processing,
    "error": DatasetStatus.error,
    "archived": DatasetStatus.archived
  ];
  return map.get(status.toLower, DatasetStatus.available);
}

// Workspace
enum WorkspaceStatus {
  active,
  inactive
}
WorkspaceStatus toWorkspaceStatus(string status) {
  const map = [
    "active": WorkspaceStatus.active,
    "inactive": WorkspaceStatus.inactive
  ];
  return map.get(status.toLower, WorkspaceStatus.inactive);
}

// GenAI Hub prompt management
enum PromptRole {
  system,
  user,
  assistant
}
PromptRole toPromptRole(string role) {
  const map = [
    "system": PromptRole.system,
    "user": PromptRole.user,
    "assistant": PromptRole.assistant
  ];
  return map.get(role.toLower, PromptRole.user);
}

enum PromptStatus {
  draft,
  active,
  archived
}
PromptStatus toPromptStatus(string status) {
  const map = [
    "draft": PromptStatus.draft,
    "active": PromptStatus.active,
    "archived": PromptStatus.archived
  ];
  return map.get(status.toLower, PromptStatus.draft);
}

// Artifact classification
enum ArtifactKind {
  model,
  dataset,
  resultset,
  other
}
ArtifactKind toArtifactKind(string kind) {
  const map = [
    "model": ArtifactKind.model,
    "dataset": ArtifactKind.dataset,
    "resultset": ArtifactKind.resultset,
    "other": ArtifactKind.other
  ];
  return map.get(kind.toLower, ArtifactKind.other);
}

// Target status for lifecycle operations
enum TargetStatus {
  running,
  stopped,
  deleted_,
  completed
}
TargetStatus toTargetStatus(string status) {
  const map = [
    "running": TargetStatus.running,
    "stopped": TargetStatus.stopped,
    "deleted": TargetStatus.deleted_,
    "completed": TargetStatus.completed
  ];
  return map.get(status.toLower, TargetStatus.completed);
}

// Metric value types
enum MetricValueType {
  float_,
  int_,
  string_
}
MetricValueType toMetricValueType(string type) {
  const map = [
    "float": MetricValueType.float_,
    "int": MetricValueType.int_,
    "string": MetricValueType.string_
  ];
  return map.get(type.toLower, MetricValueType.string_);
}

// Usage statistics
enum StatisticsPeriod {
  daily,
  weekly,
  monthly
}
StatisticsPeriod toStatisticsPeriod(string period) {
  const map = [
    "daily": StatisticsPeriod.daily,
    "weekly": StatisticsPeriod.weekly,
    "monthly": StatisticsPeriod.monthly
  ];
  return map.get(period.toLower, StatisticsPeriod.daily);
}

// Log severity levels
enum LogSeverity {
  info,
  warn,
  error
}
LogSeverity toLogSeverity(string severity) {
  const map = [
    "info": LogSeverity.info,
    "warn": LogSeverity.warn,
    "error": LogSeverity.error
  ];
  return map.get(severity.toLower, LogSeverity.info);
}

// Schedule status
enum ScheduleStatus {
  active,
  inactive
}
ScheduleStatus toScheduleStatus(string status) {
  const map = [
    "active": ScheduleStatus.active,
    "inactive": ScheduleStatus.inactive
  ];
  return map.get(status.toLower, ScheduleStatus.inactive);
}

