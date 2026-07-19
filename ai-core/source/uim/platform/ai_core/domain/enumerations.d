/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.enumerations;

import uim.platform.ai_core;
mixin(ShowModule!()); 

@safe:

// Executable types: workflow (batch), serving (inference)
enum ExecutableType {
  workflow,
  serving,
}

ExecutableType toExecutableType(string value) {
  mixin(EnumSwitch("ExecutableType", "workflow"));
}

ExecutableType[] toExecutableType(string[] values) {
  return values.map!(toExecutableType).array;
}

string toString(ExecutableType type) {
  return type.to!string; // This will return the enum member name as a string, e.g. "workflow", "serving"
}

string[] toString(ExecutableType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  assert("workflow".toExecutableType == ExecutableType.workflow);
  assert("serving".toExecutableType == ExecutableType.serving);

  assert("unknown".toExecutableType == ExecutableType.workflow);
  assert("".toExecutableType == ExecutableType.workflow);

  assert(ExecutableType.workflow.toString == "workflow");
  assert(ExecutableType.serving.toString == "serving");

  assert(toExecutableType(["workflow", "serving", "unknown"]) ==
      [ExecutableType.workflow, ExecutableType.serving, ExecutableType.workflow]);
  assert(toString([ExecutableType.workflow, ExecutableType.serving]) ==
      ["workflow", "serving"]);
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

ExecutionStatus toExecutionStatus(string value) {
  mixin(EnumSwitch("ExecutionStatus", "pending"));
}

ExecutionStatus[] toExecutionStatus(string[] statuses) {
  return statuses.map!(toExecutionStatus).array;
}

string toString(ExecutionStatus status) {
  return status.to!string; // This will return the enum member name as a string, e.g. "pending", "running", etc
}

string[] toString(ExecutionStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  assert("pending".toExecutionStatus == ExecutionStatus.pending);
  assert("running".toExecutionStatus == ExecutionStatus.running);
  assert("completed".toExecutionStatus == ExecutionStatus.completed);
  assert("failed".toExecutionStatus == ExecutionStatus.failed);
  assert("stopped".toExecutionStatus == ExecutionStatus.stopped);
  assert("dead".toExecutionStatus == ExecutionStatus.dead);

  assert("unknown".toExecutionStatus == ExecutionStatus.pending);
  assert("".toExecutionStatus == ExecutionStatus.pending);

  assert(ExecutionStatus.pending.toString == "pending");
  assert(ExecutionStatus.running.toString == "running");
  assert(ExecutionStatus.completed.toString == "completed");
  assert(ExecutionStatus.failed.toString == "failed");
  assert(ExecutionStatus.stopped.toString == "stopped");
  assert(ExecutionStatus.dead.toString == "dead");

  assert(toExecutionStatus([
      "pending", "running", "completed", "failed", "stopped", "dead", "unknown"
    ]) ==
    [
      ExecutionStatus.pending, ExecutionStatus.running, ExecutionStatus.completed,
      ExecutionStatus.failed, ExecutionStatus.stopped, ExecutionStatus.dead,
      ExecutionStatus.pending
    ]);
  assert(toString([
      ExecutionStatus.pending, ExecutionStatus.running, ExecutionStatus.completed,
      ExecutionStatus.failed, ExecutionStatus.stopped, ExecutionStatus.dead
    ]) ==
    ["pending", "running", "completed", "failed", "stopped", "dead"]);
}

// Deployment lifecycle states
enum DeploymentStatus {
  pending,
  running,
  stopped,
  dead,
  unknown,
}

DeploymentStatus toDeploymentStatus(string value) {
  mixin(EnumSwitch("DeploymentStatus", "pending"));
}

DeploymentStatus[] toDeploymentStatus(string[] statuses) {
  return statuses.map!(toDeploymentStatus).array;
}

string toString(DeploymentStatus status) {
  return status.to!string; // This will return the enum member name as a string,  e.g. "pending", "running", etc
}

string[] toString(DeploymentStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  assert("pending".toDeploymentStatus == DeploymentStatus.pending);
  assert("running".toDeploymentStatus == DeploymentStatus.running);
  assert("stopped".toDeploymentStatus == DeploymentStatus.stopped);
  assert("dead".toDeploymentStatus == DeploymentStatus.dead);

  assert("unknown".toDeploymentStatus == DeploymentStatus.pending);
  assert("".toDeploymentStatus == DeploymentStatus.pending);

  assert(DeploymentStatus.pending.toString == "pending");
  assert(DeploymentStatus.running.toString == "running");
  assert(DeploymentStatus.stopped.toString == "stopped");
  assert(DeploymentStatus.dead.toString == "dead");

  assert(toDeploymentStatus(["pending", "running", "stopped", "dead", "unknown"]) ==
      [
        DeploymentStatus.pending, DeploymentStatus.running,
        DeploymentStatus.stopped, DeploymentStatus.dead, DeploymentStatus.pending
      ]);
  assert(toString([
      DeploymentStatus.pending, DeploymentStatus.running, DeploymentStatus.stopped,
      DeploymentStatus.dead
    ]) ==
    ["pending", "running", "stopped", "dead"]);
}

// Artifact categories
enum ArtifactKind {
  model,
  dataset,
  resultset,
  other,
}

ArtifactKind toArtifactKind(string value) {
  mixin(EnumSwitch("ArtifactKind", "model"));
}

ArtifactKind[] toArtifactKind(string[] kinds) {
  return kinds.map!(toArtifactKind).array;
}

string toString(ArtifactKind kind) {
  return kind.to!string; // This will return the enum member name as a string, e.g. "model", "dataset", etc
}

string[] toString(ArtifactKind[] kinds) {
  return kinds.map!(toString).array;
}
///
unittest {
  assert("model".toArtifactKind == ArtifactKind.model);
  assert("dataset".toArtifactKind == ArtifactKind.dataset);
  assert("resultset".toArtifactKind == ArtifactKind.resultset);
  assert("other".toArtifactKind == ArtifactKind.other);

  assert("unknown".toArtifactKind == ArtifactKind.model);
  assert("".toArtifactKind == ArtifactKind.model);

  assert(ArtifactKind.model.toString == "model");
  assert(ArtifactKind.dataset.toString == "dataset");
  assert(ArtifactKind.resultset.toString == "resultset");
  assert(ArtifactKind.other.toString == "other");

  assert(toArtifactKind(["model", "dataset", "resultset", "other", "unknown"]) ==
      [
        ArtifactKind.model, ArtifactKind.dataset, ArtifactKind.resultset,
        ArtifactKind.other, ArtifactKind.model
      ]);
  assert(toString([
      ArtifactKind.model, ArtifactKind.dataset, ArtifactKind.resultset,
      ArtifactKind.other
    ]) ==
    ["model", "dataset", "resultset", "other"]);
}

// Target state for PATCH operations
enum TargetStatus : string {
  running = "RUNNING",
  stopped = "STOPPED",
  deleted_ = "DELETED",
  completed = "COMPLETED",
}

TargetStatus toTargetStatus(string value) {
  switch (value.toLower) {
  case "running":
    return TargetStatus.running;
  case "stopped":
    return TargetStatus.stopped;
  case "deleted":
    return TargetStatus.deleted_;
  case "completed":
    return TargetStatus.completed;
  default:
    return TargetStatus.running; // Default to running if unknown
  }
}

TargetStatus[] toTargetStatus(string[] statuses) {
  return statuses.map!(toTargetStatus).array;
}

string toString(TargetStatus status) {
  return cast(string)status; // This will return the enum member name as a string, e.g. "running", "stopped", etc
}

string[] toString(TargetStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  assert("running".toTargetStatus == TargetStatus.running);
  assert("stopped".toTargetStatus == TargetStatus.stopped);
  assert("deleted".toTargetStatus == TargetStatus.deleted_);
  assert("completed".toTargetStatus == TargetStatus.completed);

  assert("unknown".toTargetStatus == TargetStatus.running);
  assert("".toTargetStatus == TargetStatus.running);

  assert(TargetStatus.running.toString == "RUNNING");
  assert(TargetStatus.stopped.toString == "STOPPED");
  assert(TargetStatus.deleted_.toString == "DELETED");
  assert(TargetStatus.completed.toString == "COMPLETED");

  assert(toTargetStatus([
      "running", "stopped", "deleted", "completed", "unknown"
    ]) ==
    [
      TargetStatus.running, TargetStatus.stopped, TargetStatus.deleted_,
      TargetStatus.completed, TargetStatus.running
    ]);
  assert(toString([
      TargetStatus.running, TargetStatus.stopped, TargetStatus.deleted_,
      TargetStatus.completed
    ]) ==
    ["RUNNING", "STOPPED", "DELETED", "COMPLETED"]);
}

// Metric value types
enum MetricValueType : string {
  string_ = "string",
  float_ = "float",
  int_ = "int",
}

MetricValueType toMetricValueType(string value) {
  switch (value.toLower) {
  case "float":
    return MetricValueType.float_;
  case "int":
    return MetricValueType.int_;
  case "string":
    return MetricValueType.string_;
  default:
    return MetricValueType.string_; // Default to string if unknown
  }
}

MetricValueType[] toMetricValueType(string[] values) {
  return values.map!(toMetricValueType).array;
}

string toString(MetricValueType type) {
  return cast(string)type; // This will return the enum member name as a string, e.g. "string_", "float_", "int_"
}

string[] toString(MetricValueType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  assert("string".toMetricValueType == MetricValueType.string_);
  assert("float".toMetricValueType == MetricValueType.float_);
  assert("int".toMetricValueType == MetricValueType.int_);

  assert("unknown".toMetricValueType == MetricValueType.string_);
  assert("".toMetricValueType == MetricValueType.string_);

  assert(MetricValueType.string_.toString == "string_");
  assert(MetricValueType.float_.toString == "float_");
  assert(MetricValueType.int_.toString == "int_");

  assert(toMetricValueType(["string", "float", "int", "unknown"]) ==
      [
        MetricValueType.string_, MetricValueType.float_, MetricValueType.int_,
        MetricValueType.string_
      ]);
  assert(toString([
      MetricValueType.string_, MetricValueType.float_, MetricValueType.int_
    ]) ==
    ["string_", "float_", "int_"]);
}

// Log severity levels
enum LogSeverity {
  info,
  warn,
  error,
}

LogSeverity toLogSeverity(string value) {
  mixin(EnumSwitch("LogSeverity", "info"));
}

LogSeverity[] toLogSeverity(string[] values) {
  return values.map!(toLogSeverity).array;
}

string toString(LogSeverity severity) {
  return severity.to!string; // This will return the enum member name as a string, e.g. "info", "warn", "error"
}

string[] toString(LogSeverity[] severities) {
  return severities.map!(toString).array;
}
///
unittest {
  assert("info".toLogSeverity == LogSeverity.info);
  assert("warn".toLogSeverity == LogSeverity.warn);
  assert("error".toLogSeverity == LogSeverity.error);

  assert("unknown".toLogSeverity == LogSeverity.info);
  assert("".toLogSeverity == LogSeverity.info);

  assert(LogSeverity.info.toString == "info");
  assert(LogSeverity.warn.toString == "warn");
  assert(LogSeverity.error.toString == "error");

  assert(toLogSeverity(["info", "warn", "error", "unknown"]) ==
      [LogSeverity.info, LogSeverity.warn, LogSeverity.error, LogSeverity.info]);
  assert(toString([LogSeverity.info, LogSeverity.warn, LogSeverity.error]) ==
      ["info", "warn", "error"]);
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

ScheduleStatus toScheduleStatus(string value) {
  mixin(EnumSwitch("ScheduleStatus", "active"));
}

ScheduleStatus[] toScheduleStatus(string[] statuses) {
  return statuses.map!(toScheduleStatus).array;
}

string toString(ScheduleStatus status) {
  return status.to!string; // This will return the enum member name as a string, e.g. "active", "inactive", etc
}

string[] toString(ScheduleStatus[] statuses) {
  return statuses.map!(toString).array;
}
///
unittest {
  assert("active".toScheduleStatus == ScheduleStatus.active);
  assert("inactive".toScheduleStatus == ScheduleStatus.inactive);
  assert("deleted".toScheduleStatus == ScheduleStatus.deleted);
  assert("error".toScheduleStatus == ScheduleStatus.error);
  assert("completed".toScheduleStatus == ScheduleStatus.completed);
  assert("deleting".toScheduleStatus == ScheduleStatus.deleting);
  assert("updated".toScheduleStatus == ScheduleStatus.updated);
  assert("suspended_nonpayment".toScheduleStatus == ScheduleStatus.suspended_nonpayment);
  assert("suspended_abuse".toScheduleStatus == ScheduleStatus.suspended_abuse);
  assert("suspended_legal".toScheduleStatus == ScheduleStatus.suspended_legal);
  assert("suspended_security".toScheduleStatus == ScheduleStatus.suspended_security);
  assert("suspended_policy".toScheduleStatus == ScheduleStatus.suspended_policy);
  assert("suspended_other".toScheduleStatus == ScheduleStatus.suspended_other);

  assert("unknown".toScheduleStatus == ScheduleStatus.active);
  assert("".toScheduleStatus == ScheduleStatus.active);

  assert(ScheduleStatus.active.toString == "active");
  assert(ScheduleStatus.inactive.toString == "inactive");
  assert(ScheduleStatus.deleted.toString == "deleted");
  assert(ScheduleStatus.error.toString == "error");
  assert(ScheduleStatus.completed.toString == "completed");
  assert(ScheduleStatus.deleting.toString == "deleting");
  assert(ScheduleStatus.updated.toString == "updated");
  assert(ScheduleStatus.suspended_nonpayment.toString == "suspended_nonpayment");
  assert(ScheduleStatus.suspended_abuse.toString == "suspended_abuse");
  assert(ScheduleStatus.suspended_legal.toString == "suspended_legal");
  assert(ScheduleStatus.suspended_security.toString == "suspended_security");
  assert(ScheduleStatus.suspended_policy.toString == "suspended_policy");
  assert(ScheduleStatus.suspended_other.toString == "suspended_other");

  assert(toScheduleStatus([
      "active", "inactive", "deleted", "error", "completed", "deleting", "updated",
      "suspended_nonpayment", "suspended_abuse", "suspended_legal",
      "suspended_security", "suspended_policy", "suspended_other", "unknown"
    ]) ==
    [
      ScheduleStatus.active, ScheduleStatus.inactive, ScheduleStatus.deleted,
      ScheduleStatus.error, ScheduleStatus.completed, ScheduleStatus.deleting,
      ScheduleStatus.updated, ScheduleStatus.suspended_nonpayment,
      ScheduleStatus.suspended_abuse, ScheduleStatus.suspended_legal,
      ScheduleStatus.suspended_security, ScheduleStatus.suspended_policy,
      ScheduleStatus.suspended_other, ScheduleStatus.active
    ]);
  assert(toString([
      ScheduleStatus.active, ScheduleStatus.inactive, ScheduleStatus.deleted,
      ScheduleStatus.error, ScheduleStatus.completed, ScheduleStatus.deleting,
      ScheduleStatus.updated, ScheduleStatus.suspended_nonpayment,
      ScheduleStatus.suspended_abuse, ScheduleStatus.suspended_legal,
      ScheduleStatus.suspended_security, ScheduleStatus.suspended_policy,
      ScheduleStatus.suspended_other
    ]) ==
    [
      "active", "inactive", "deleted", "error", "completed", "deleting", "updated",
      "suspended_nonpayment", "suspended_abuse", "suspended_legal",
      "suspended_security", "suspended_policy", "suspended_other"
    ]);
}
