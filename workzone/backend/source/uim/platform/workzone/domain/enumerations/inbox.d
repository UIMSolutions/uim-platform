/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.enumerations.inbox;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Lifecycle of a task (overdue is set by housekeeping when dueAt has passed).
enum TaskStatus {
  open,
  inProgress,
  overdue,
  completed,
  cancelled,
}

/// True while the task still needs work.
bool isPending(TaskStatus s) pure nothrow {
  return s == TaskStatus.open || s == TaskStatus.inProgress || s == TaskStatus.overdue;
}

enum TaskPriority {
  low,
  medium,
  high,
  veryHigh,
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

/// Inbox state of a notification.
enum NotificationStatus {
  unread,
  read_,
  actionRequired,
  dismissed,
}

///
unittest {
  assert(TaskStatus.overdue.isPending && !TaskStatus.completed.isPending);
  assert(enumText(NotificationStatus.read_) == "read");
  assert(parseEnum!NotificationStatus("read", NotificationStatus.unread) == NotificationStatus.read_);
}
