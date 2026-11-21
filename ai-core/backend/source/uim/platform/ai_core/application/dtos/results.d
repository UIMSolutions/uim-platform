/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Results of use cases and application services.
module uim.platform.ai_core.application.dtos.results;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Outcome of one item of a bulk PATCH.
struct BulkResult {
  string id;
  bool ok;
  int status = 202; /// AI API per-item status (202 accepted, 404, 412, 400)
  string message;
}

/// What a reconciler run changed.
struct ReconcileResult {
  size_t resourceGroupsProvisioned;
  size_t executionsStarted;
  size_t executionsCompleted;
  size_t executionsStopped;
  size_t deploymentsStarted;
  size_t deploymentsStopped;
  size_t deploymentsExpired;
  size_t schedulesFired;
  size_t artifactsCreated;

  size_t total() const {
    return resourceGroupsProvisioned + executionsStarted + executionsCompleted + executionsStopped + deploymentsStarted
      + deploymentsStopped + deploymentsExpired + schedulesFired;
  }

  void add(const ReconcileResult r) {
    resourceGroupsProvisioned += r.resourceGroupsProvisioned;
    executionsStarted += r.executionsStarted;
    executionsCompleted += r.executionsCompleted;
    executionsStopped += r.executionsStopped;
    deploymentsStarted += r.deploymentsStarted;
    deploymentsStopped += r.deploymentsStopped;
    deploymentsExpired += r.deploymentsExpired;
    schedulesFired += r.schedulesFired;
    artifactsCreated += r.artifactsCreated;
  }
}

/// Key figures of a tenant (Statistics singleton, KPI header, CLI stats).
struct AiCoreStatistics {
  string tenantId;
  size_t resourceGroups;
  size_t scenarios;
  size_t executables;
  size_t configurations;
  size_t executions;
  size_t pendingExecutions;
  size_t runningExecutions;
  size_t completedExecutions;
  size_t failedExecutions; /// DEAD or STOPPED
  size_t deployments;
  size_t runningDeployments;
  size_t stoppedDeployments;
  size_t artifacts;
  size_t models;
  size_t datasets;
  size_t schedules;
  size_t activeSchedules;
  size_t metrics;
  size_t secrets;
  long computedAt;
}
