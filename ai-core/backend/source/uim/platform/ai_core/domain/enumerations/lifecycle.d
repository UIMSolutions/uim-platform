/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Lifecycle states of the AI API v2 (values exactly as on the wire).
module uim.platform.ai_core.domain.enumerations.lifecycle;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Status of an execution (training run).
enum ExecutionStatus : string {
  unknown = "UNKNOWN",
  pending = "PENDING",
  running = "RUNNING",
  completed = "COMPLETED",
  dead = "DEAD",
  stopping = "STOPPING",
  stopped = "STOPPED"
}

/// Status of a deployment (serving runtime).
enum DeploymentStatus : string {
  unknown = "UNKNOWN",
  pending = "PENDING",
  running = "RUNNING",
  completed = "COMPLETED",
  dead = "DEAD",
  stopping = "STOPPING",
  stopped = "STOPPED"
}

/// Status requested by the client (PATCH targetStatus).
enum TargetStatus : string {
  running = "RUNNING",
  completed = "COMPLETED",
  stopped = "STOPPED",
  deleted = "DELETED"
}

/// Status of a resource group (provisioned asynchronously).
enum ResourceGroupStatus : string {
  provisioning = "PROVISIONING",
  provisioned = "PROVISIONED",
  error = "ERROR"
}

/// Status of an execution schedule.
enum ScheduleStatus : string {
  active = "ACTIVE",
  inactive = "INACTIVE"
}

/// Last operation on a deployment.
enum DeploymentOperation : string {
  create = "CREATE",
  update = "UPDATE",
  delete_ = "DELETE",
  cascadeUpdate = "CASCADE-UPDATE"
}

/// True for states that never change on their own.
bool isFinal(ExecutionStatus s) pure {
  return s == ExecutionStatus.completed || s == ExecutionStatus.dead || s == ExecutionStatus.stopped;
}

/// True while the runtime holds resources.
bool isActive(ExecutionStatus s) pure {
  return s == ExecutionStatus.pending || s == ExecutionStatus.running || s == ExecutionStatus.stopping;
}

/// ditto
bool isActive(DeploymentStatus s) pure {
  return s == DeploymentStatus.pending || s == DeploymentStatus.running || s == DeploymentStatus.stopping;
}

///
unittest {
  assert(isFinal(ExecutionStatus.completed) && !isFinal(ExecutionStatus.running));
  assert(isActive(ExecutionStatus.stopping) && !isActive(ExecutionStatus.stopped));
  assert(isActive(DeploymentStatus.running) && !isActive(DeploymentStatus.dead));
}
