/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.enumerations.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Lifecycle status of a task (see domain.services.task_lifecycle).
enum TaskStatus : string {
  open = "open", /// waiting for a processor
  reserved = "reserved", /// reserved by the provider for a user (not yet claimed here)
  inProgress = "inProgress", /// claimed by a processor
  forwarded = "forwarded", /// handed over to another user
  completed = "completed", /// final: decided / done
  cancelled = "cancelled", /// final: withdrawn
  failed = "failed" /// final: the provider reported an error
}

enum TaskPriority : string {
  low = "low",
  medium = "medium",
  high = "high",
  veryHigh = "veryHigh"
}

enum TaskCategory : string {
  approval = "approval",
  review = "review",
  toDoItem = "toDoItem",
  notification = "notification",
  action = "action",
  workflow = "workflow",
  informational = "informational"
}

/// Result of a finished task.
enum TaskOutcome : string {
  none = "none",
  approved = "approved",
  rejected = "rejected",
  completed = "completed",
  cancelled = "cancelled"
}

/// True for completed, cancelled and failed.
bool isFinal(TaskStatus status) pure nothrow {
  return status == TaskStatus.completed || status == TaskStatus.cancelled || status == TaskStatus.failed;
}

/// Ordinal of a priority (low = 0 … veryHigh = 3).
int rankOf(TaskPriority p) pure nothrow {
  final switch (p) {
  case TaskPriority.low:
    return 0;
  case TaskPriority.medium:
    return 1;
  case TaskPriority.high:
    return 2;
  case TaskPriority.veryHigh:
    return 3;
  }
}

///
unittest {
  assert(TaskStatus.completed.isFinal && !TaskStatus.forwarded.isFinal);
  assert(rankOf(TaskPriority.veryHigh) > rankOf(TaskPriority.high));
}
