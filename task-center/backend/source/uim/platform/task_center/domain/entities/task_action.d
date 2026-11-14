/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_action;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Immutable audit record of an action performed on a task.
struct TaskAction {
  mixin TenantEntity!TaskActionId;

  TaskId taskId;
  ActionType actionType = ActionType.claim;
  string performedBy;
  long performedAt; /// std time
  string forwardTo;
  string comment;
  TaskStatus fromStatus = TaskStatus.open;
  TaskStatus toStatus = TaskStatus.open;
}
