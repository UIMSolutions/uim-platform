/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Statistics of a tenant (KPI header, CLI "stats").
module uim.platform.integration_automation.application.services.statistics;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class IaStatisticsService : IIaStatisticsService {
  protected IaRepositories repos;
  protected IClock clock;
  protected IaPolicy policy;

  this(IaRepositories repos, IClock clock, IaPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.policy = policy;
  }

  IaStatistics compute(TenantId t, string user) {
    IaStatistics s;
    s.tenantId = t;
    s.maxOpenWorkflows = policy.maxOpenWorkflows;
    foreach (sys; repos.systems.findAll(t)) {
      s.systems++;
      if (sys.status == ConnectionStatus.active)
        s.reachableSystems++;
      else if (sys.status == ConnectionStatus.error)
        s.unreachableSystems++;
    }
    s.destinations = repos.destinations.countAll(t);
    foreach (sc; repos.scenarios.findAll(t)) {
      s.scenarios++;
      if (sc.isActive)
        s.activeScenarios++;
      else if (sc.isDraft)
        s.draftScenarios++;
    }

    bool[string] openWorkflow;
    long finished;
    foreach (wf; repos.workflows.findAll(t)) {
      s.workflows++;
      if (wf.isOpen) {
        s.openWorkflows++;
        openWorkflow[wf.id.value] = true;
      }
      final switch (wf.status) {
      case WorkflowStatus.inProgress:
        s.runningWorkflows++;
        break;
      case WorkflowStatus.suspended:
        s.suspendedWorkflows++;
        break;
      case WorkflowStatus.failed:
        s.failedWorkflows++;
        break;
      case WorkflowStatus.completed:
        s.completedWorkflows++;
        finished++;
        break;
      case WorkflowStatus.terminated:
        finished++;
        break;
      case WorkflowStatus.planned:
        break;
      }
    }
    s.completionRate = finished == 0 ? 0 : s.completedWorkflows * 100 / finished;

    WorkflowTask[][string] byWorkflow;
    foreach (task; repos.workflowTasks.findAll(t))
      byWorkflow[task.workflowId.value] ~= task;
    foreach (wfId, tasks; byWorkflow)
      foreach (task; tasks) {
        s.tasks++;
        if (task.taskType == TaskType.automated)
          s.automatedTasks++;
        if (task.status == TaskStatus.failed)
          s.failedTasks++;
        if ((wfId in openWorkflow) is null)
          continue;
        if (task.status == TaskStatus.pending || task.status == TaskStatus.inProgress) {
          s.openTasks++;
          if (user.length && task.assignedTo == user)
            s.myOpenTasks++;
        }
        if (isReady(task, tasks))
          s.readyTasks++;
      }

    auto since = plusDays(clock.now, -1);
    foreach (l; repos.executionLogs.findAll(t)) {
      s.executionLogs++;
      if (l.createdAt >= since && (l.outcome == ExecutionOutcome.failure || l.outcome == ExecutionOutcome.timeout))
        s.failuresLast24h++;
    }
    return s;
  }
}
