/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.manage_tasks;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IManageTasks {
  UIMTask[] listTasks(TenantId tenantId);
  UIMTask getTask(TenantId tenantId, TaskId id);
  /// Applies the definition defaults (category, priority, actions, SLA) and substitution rules.
  UIMTask createTask(CreateTaskRequest request);
  /// Content only — the status changes through IProcessTasks.
  UIMTask updateTask(UpdateTaskRequest request);
  /// Removes comments, attachments and the action history as well.
  void deleteTask(TenantId tenantId, TaskId id);
}
