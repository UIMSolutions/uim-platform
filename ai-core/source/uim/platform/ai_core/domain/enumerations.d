/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.enumerations;

import uim.platform.ai_core;

// mixin(ShowModule!()); 

@safe:

// Executable types: workflow (batch), serving (inference)
enum ExecutableType {
  workflow,
  serving,
}

ExecutableType toExecutableType(string type) {
  const map = [
    "workflow": ExecutableType.workflow,
    "serving": ExecutableType.serving
  ];
  return map.get(type.toLower, ExecutableType.workflow);
}

// Execution lifecycle states
enum ExecutionStatus {
  pending,
  running,
  completed,
  failed,
  stopped,
  dead,
  unknown,
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

// Deployment lifecycle states
enum DeploymentStatus {
  pending,
  running,
  stopped,
  dead,
  unknown,
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

// Artifact categories
enum ArtifactKind {
  model,
  dataset,
  resultset,
  other,
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

// Target state for PATCH operations
enum TargetStatus {
  running,
  stopped,
  deleted_,
  completed,
}

TargetStatus toTargetStatus(string status) {
  const map = [
    "running": TargetStatus.running,
    "stopped": TargetStatus.stopped,
    "deleted": TargetStatus.deleted_,
    "completed": TargetStatus.completed
  ];
  return map.get(status.toLower, TargetStatus.stopped);
}

// Metric value types
enum MetricValueType {
  float_,
  int_,
  string_,
}

MetricValueType toMetricValueType(string type) {
  const map = [
    "float": MetricValueType.float_,
    "int": MetricValueType.int_,
    "string": MetricValueType.string_
  ];
  return map.get(type.toLower, MetricValueType.string_);
}

// Log severity levels
enum LogSeverity {
  info,
  warn,
  error,
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
  // Used for schedules that are currently active and will trigger executions according to their defined schedule
  active,
  // Used for schedules that have been deactivated, which may indicate that they are no longer in use or have been temporarily disabled, and will not trigger any executions until they are reactivated
  inactive,
  // Used for schedules that have been deleted, which may indicate that they are no longer in use and have been removed from the system
  deleted,
  // Used for schedules that have encountered an error during the scheduling or execution process, which may require troubleshooting and resolution before they can be reactivated or used again
  error,
  // Used for schedules that have been completed, which may indicate that they have reached their end date or have fulfilled their intended purpose, and may require review or archiving before they can be reactivated or used again
  completed,
  // Used for schedules that are in the process of being deleted, which may indicate that they are still active but may require additional steps to complete the deletion process and remove them from the system
  deleting,
  // Used for schedules that have been deleted but are still within the retention period, which may indicate that they can be restored or reactivated before they are permanently removed from the system
  deleted_retention,
  // Used for schedules that have been deleted and are no longer within the retention period, which may indicate that they are permanently removed from the system and cannot be restored or reactivated
  deleted_expired,
  // Used for schedules that are in the process of being restored from deletion, which may indicate that they are still deleted but may require additional steps to complete the restoration process and reactivate them
  restoring,
  // Used for schedules that have been restored from deletion, which may indicate that they are now active again after being deleted and can be used as before
  restored,

  // Used for schedules that are in the process of being triggered, which may indicate that they are still active but may require additional steps to complete the triggering process and execute the associated workflow or serving
  triggering,
  // Used for schedules that have been triggered and are currently executing, which may indicate that they
  // are still active but may require monitoring and management during the execution process, and may transition to other statuses such as completed, failed, or error based on the execution outcome
  executing,
  // Used for schedules that have been triggered but have encountered an error during the triggering or execution process, which may require troubleshooting and resolution before they can be reactivated or used again
  triggered_error,
  // Used for schedules that have been triggered and have completed execution, which may indicate that they have fulfilled their intended purpose and may require review or archiving before they can be reactivated or used again
  triggered_completed,
  // Used for schedules that are in the process of being updated, which may indicate that they are still active but may require additional steps to complete the update process and apply the changes to the schedule
  updating,
  // Used for schedules that have been updated, which may indicate that they are now active with the updated configuration and can be used as before, but may require monitoring to ensure that the changes have
  // been applied correctly and that the schedule is functioning as intended
  updated,
  // Used for schedules that have been suspended due to non-payment, which may indicate that they are temporarily inactive until the outstanding payment is resolved and the schedule can be reactivated
  suspended_nonpayment,
  // Used for schedules that have been suspended due to abuse, which may indicate that they are temporarily inactive until the abuse issue is resolved and the schedule can be reactivated
  suspended_abuse,
  // Used for schedules that have been suspended due to legal issues, which may indicate that they are temporarily inactive until the legal issue is resolved and the schedule can be reactivated
  suspended_legal,
  // Used for schedules that have been suspended due to security issues, which may indicate that they are temporarily inactive until the security issue is resolved and the schedule can be reactivated
  suspended_security,
  // Used for schedules that have been suspended due to policy violations, which may indicate that they are temporarily inactive until the policy violation is resolved and the schedule can be reactivated
  suspended_policy,
  // Used for schedules that have been suspended due to other reasons, which may indicate that they are temporarily inactive until the underlying issue is resolved and the schedule can be reactivated
  suspended_other,
}

ScheduleStatus toScheduleStatus(string status) {
  const map = [
    "active": ScheduleStatus.active,
    "inactive": ScheduleStatus.inactive,
    "deleted": ScheduleStatus.deleted,
    "error": ScheduleStatus.error,
    "completed": ScheduleStatus.completed,
    "deleting": ScheduleStatus.deleting,
    "deleted_retention": ScheduleStatus.deleted_retention,
    "deleted_expired": ScheduleStatus.deleted_expired,
    "restoring": ScheduleStatus.restoring,
    "restored": ScheduleStatus.restored,
    "suspended_security": ScheduleStatus.suspended_security,
    "suspended_policy": ScheduleStatus.suspended_policy,
    "suspended_other": ScheduleStatus.suspended_other,
    "triggering": ScheduleStatus.triggering,
    "executing": ScheduleStatus.executing,
    "triggered_error": ScheduleStatus.triggered_error,
    "triggered_completed": ScheduleStatus.triggered_completed
  ];
  return map.get(status.toLower, ScheduleStatus.inactive);
}
