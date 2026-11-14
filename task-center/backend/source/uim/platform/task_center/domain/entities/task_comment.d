/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_comment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// A comment on a task. Only its author may change or delete it.
struct TaskComment {
  mixin TenantEntity!TaskCommentId;

  TaskId taskId;
  string author;
  string content;

  void validate() const {
    if (taskId.isNull)
      throw TaskCenterException.invalid("Comment needs a taskId");
    requireText(content, "Comment content");
    if (content.length > 10_000)
      throw TaskCenterException.invalid("Comment exceeds 10000 characters");
  }
}
