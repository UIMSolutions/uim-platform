/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of the runtime: executions, deployments, schedules,
/// metrics and the lifecycle reconciler.
module uim.platform.ai_core.ports.usecases.runtime;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

interface IManageExecutions {
  Execution createExecution(CreateExecutionRequest r);
  Execution patchExecution(PatchExecutionRequest r);
  BulkResult[] patchExecutions(TenantId t, ResourceGroupId rg, UserId actor, const string[] ids, string targetStatus);
  Execution getExecution(TenantId t, ResourceGroupId rg, ExecutionId id);
  Execution[] listExecutions(TenantId t, ResourceGroupId rg, RunFilter filter = RunFilter.init);
  /// Refused while the execution is PENDING, RUNNING or STOPPING. Removes its metrics.
  void deleteExecution(TenantId t, ResourceGroupId rg, ExecutionId id);
}

interface IManageDeployments {
  Deployment createDeployment(CreateDeploymentRequest r);
  Deployment patchDeployment(PatchDeploymentRequest r);
  BulkResult[] patchDeployments(TenantId t, ResourceGroupId rg, UserId actor, const string[] ids, string targetStatus);
  Deployment getDeployment(TenantId t, ResourceGroupId rg, DeploymentId id);
  Deployment[] listDeployments(TenantId t, ResourceGroupId rg, RunFilter filter = RunFilter.init);
  /// Refused while the deployment is PENDING, RUNNING or STOPPING.
  void deleteDeployment(TenantId t, ResourceGroupId rg, DeploymentId id);
}

interface IManageSchedules {
  ExecutionSchedule createSchedule(CreateScheduleRequest r);
  ExecutionSchedule updateSchedule(UpdateScheduleRequest r);
  ExecutionSchedule getSchedule(TenantId t, ResourceGroupId rg, ScheduleId id);
  ExecutionSchedule[] listSchedules(TenantId t, ResourceGroupId rg, ConfigurationId configuration = ConfigurationId.init);
  void deleteSchedule(TenantId t, ResourceGroupId rg, ScheduleId id);
  /// Start an execution now (independent of the cron expression).
  Execution triggerSchedule(TenantId t, ResourceGroupId rg, ScheduleId id, UserId actor);
}

interface IManageMetrics {
  /// Log metric values and execution tags; returns the number of stored values.
  size_t logMetrics(LogMetricsRequest r);
  Metric[] listMetrics(TenantId t, ResourceGroupId rg, ExecutionId execution = ExecutionId.init);
  Metric getMetric(TenantId t, ResourceGroupId rg, MetricId id);
  void deleteMetric(TenantId t, ResourceGroupId rg, MetricId id);
  /// Remove all metrics of an execution; returns the number removed.
  size_t clearMetrics(TenantId t, ResourceGroupId rg, ExecutionId execution);
}

interface IReconcileLifecycle {
  /// Advance all resource groups, executions, deployments and due schedules of a tenant.
  ReconcileResult reconcile(TenantId t);
}
