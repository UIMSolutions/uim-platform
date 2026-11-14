/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.services.statistics;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskCenterStatisticsService : ITaskCenterStatistics {
  protected ITaskRepository tasks;
  protected ITaskProviderRepository providers;
  protected ITaskDefinitionRepository definitions;
  protected ISubstitutionRuleRepository substitutions;
  protected ITaskCommentRepository comments;
  protected ITaskAttachmentRepository attachments;
  protected ITaskActionRepository actions;

  this(ITaskRepository tasks, ITaskProviderRepository providers, ITaskDefinitionRepository definitions,
    ISubstitutionRuleRepository substitutions, ITaskCommentRepository comments, ITaskAttachmentRepository attachments,
    ITaskActionRepository actions) {
    this.tasks = tasks;
    this.providers = providers;
    this.definitions = definitions;
    this.substitutions = substitutions;
    this.comments = comments;
    this.attachments = attachments;
    this.actions = actions;
  }

  TaskCenterStatistics compute(TenantId tenantId) {
    TaskCenterStatistics s;
    s.tenantId = tenantId.value;
    auto today = todayIso();
    foreach (t; tasks.findAll(tenantId)) {
      s.tasks++;
      final switch (t.status) {
      case TaskStatus.open, TaskStatus.reserved, TaskStatus.forwarded:
        s.openTasks++;
        break;
      case TaskStatus.inProgress:
        s.inProgressTasks++;
        break;
      case TaskStatus.completed:
        s.completedTasks++;
        break;
      case TaskStatus.cancelled:
        s.cancelledTasks++;
        break;
      case TaskStatus.failed:
        s.failedTasks++;
        break;
      }
      if (t.isOverdue(today))
        s.overdueTasks++;
      if (!t.isFinished && rankOf(t.priority) >= rankOf(TaskPriority.high))
        s.highPriorityTasks++;
      if (!t.isFinished && t.assignee.length == 0)
        s.unassignedTasks++;
      if (t.outcome == TaskOutcome.approved)
        s.approvedTasks++;
      if (t.outcome == TaskOutcome.rejected)
        s.rejectedTasks++;
    }
    foreach (p; providers.findAll(tenantId)) {
      s.providers++;
      if (p.status == ProviderStatus.active || p.status == ProviderStatus.syncing)
        s.activeProviders++;
      if (p.status == ProviderStatus.error)
        s.providersInError++;
    }
    s.definitions = definitions.countAll(tenantId);
    s.activeSubstitutions = substitutions.findAll(tenantId).count!(r => r.effectiveStatus(today) == SubstitutionStatus.active);
    s.comments = comments.countAll(tenantId);
    s.attachments = attachments.countAll(tenantId);
    s.actions = actions.countAll(tenantId);
    return s;
  }
}
