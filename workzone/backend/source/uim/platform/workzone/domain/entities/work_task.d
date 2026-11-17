/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.work_task;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A task in "My Inbox" (own or federated from a business system).
struct WorkTask {
  mixin TenantEntity!TaskId;

  UserId assigneeId;
  string assigneeName;
  string title;
  string description;
  TaskStatus status = TaskStatus.open;
  TaskPriority priority = TaskPriority.medium;
  string sourceApp; /// originating system
  string sourceTaskId; /// id in the originating system
  string actionUrl; /// deep link
  string category;
  string[] tags;
  long dueAt; /// 0 = no due date
  long completedAt;
}
