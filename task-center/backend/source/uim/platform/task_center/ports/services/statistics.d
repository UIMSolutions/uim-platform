/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.services.statistics;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Key figures of a tenant (OData singleton "Statistics").
struct TaskCenterStatistics {
  string tenantId;
  size_t tasks;
  size_t openTasks; /// open, reserved, forwarded
  size_t inProgressTasks;
  size_t completedTasks;
  size_t cancelledTasks;
  size_t failedTasks;
  size_t overdueTasks;
  size_t highPriorityTasks; /// high / veryHigh and not finished
  size_t unassignedTasks; /// not finished, no assignee
  size_t approvedTasks;
  size_t rejectedTasks;
  size_t providers;
  size_t activeProviders;
  size_t providersInError;
  size_t definitions;
  size_t activeSubstitutions;
  size_t comments;
  size_t attachments;
  size_t actions;
}

interface ITaskCenterStatistics {
  TaskCenterStatistics compute(TenantId tenantId);
}
