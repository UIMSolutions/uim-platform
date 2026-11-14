/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.ports.usecases.manage_collaboration;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

interface IManageTaskComments {
  TaskComment[] listTaskComments(TenantId tenantId);
  TaskComment getTaskComment(TenantId tenantId, TaskCommentId id);
  TaskComment createTaskComment(CreateTaskCommentRequest request);
  /// Only the author (or a privileged caller) may change or delete a comment.
  TaskComment updateTaskComment(UpdateTaskCommentRequest request);
  void deleteTaskComment(TenantId tenantId, TaskCommentId id, UserId actor, bool privileged);
}

interface IManageTaskAttachments {
  TaskAttachment[] listTaskAttachments(TenantId tenantId);
  TaskAttachment getTaskAttachment(TenantId tenantId, TaskAttachmentId id);
  TaskAttachment createTaskAttachment(CreateTaskAttachmentRequest request);
  TaskAttachment updateTaskAttachment(UpdateTaskAttachmentRequest request);
  void deleteTaskAttachment(TenantId tenantId, TaskAttachmentId id);
}
