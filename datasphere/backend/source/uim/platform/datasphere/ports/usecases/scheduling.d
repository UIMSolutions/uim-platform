/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of scheduling and monitoring: tasks, task chains and the
/// run log.
module uim.platform.datasphere.ports.usecases.scheduling;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IManageTasks : IManageResource!(DataTask, TaskId, TaskInput) {
  /// Run now (with the retries of the task).
  TaskRun runTask(TenantId t, TaskId id, UserId actor);
  DataTask pause(TenantId t, TaskId id, UserId actor);
  DataTask resume(TenantId t, TaskId id, UserId actor);
}

interface IManageTaskChains : IManageResource!(TaskChain, TaskChainId, TaskChainInput) {
  /// Run the steps now; the result is the run of the chain (steps: runs with chainRunId).
  TaskRun runChain(TenantId t, TaskChainId id, UserId actor);
  TaskChain pause(TenantId t, TaskChainId id, UserId actor);
  TaskChain resume(TenantId t, TaskChainId id, UserId actor);
}

interface IMonitorRuns {
  /// All runs of the tenant (oldest first).
  TaskRun[] listRuns(TenantId t);
  TaskRun getRun(TenantId t, TaskRunId id);
  /// Run every task and task chain whose schedule is due.
  SchedulerSummary runDue(TenantId t, UserId actor);
  /// Remove finished runs older than the retention.
  PurgeResult purgeRuns(TenantId t, UserId actor);
}
