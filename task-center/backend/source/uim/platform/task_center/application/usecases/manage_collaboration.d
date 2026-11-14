/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage_collaboration;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskCommentsUseCase : IManageTaskComments {
  protected ITaskCommentRepository comments;
  protected ITaskRepository tasks;
  protected ITaskEventPublisher events;

  this(ITaskCommentRepository comments, ITaskRepository tasks, ITaskEventPublisher events) {
    this.comments = comments;
    this.tasks = tasks;
    this.events = events;
  }

  TaskComment[] listTaskComments(TenantId tenantId) {
    return comments.findAll(tenantId);
  }

  TaskComment getTaskComment(TenantId tenantId, TaskCommentId id) {
    return comments.findById(tenantId, id).required("Comment '" ~ id.value ~ "'");
  }

  TaskComment createTaskComment(CreateTaskCommentRequest r) {
    auto task = tasks.findById(r.tenantId, TaskId(r.taskId.strip)).required("Task '" ~ r.taskId ~ "'");
    TaskComment c;
    stampCreated!(TaskComment, TaskCommentId)(c, r.tenantId, r.actor, r.id);
    if (comments.existsById(r.tenantId, c.id))
      throw TaskCenterException.conflict("Comment '" ~ c.id.value ~ "' already exists");
    c.taskId = task.id;
    c.author = r.actor.value;
    c.content = r.content.strip;
    c.validate();
    comments.save(c);
    publishTaskEvent(events, task, "commented", r.actor.value);
    return c;
  }

  TaskComment updateTaskComment(UpdateTaskCommentRequest r) {
    auto c = getTaskComment(r.tenantId, r.id);
    requireOwner(c.author, r.actor, r.privileged, "comment");
    r.content.applyTo(c.content);
    c.content = c.content.strip;
    c.validate();
    stampUpdated(c, r.actor);
    comments.save(c);
    return c;
  }

  void deleteTaskComment(TenantId tenantId, TaskCommentId id, UserId actor, bool privileged) {
    auto c = getTaskComment(tenantId, id);
    requireOwner(c.author, actor, privileged, "comment");
    comments.removeById(tenantId, id);
  }
}

class ManageTaskAttachmentsUseCase : IManageTaskAttachments {
  protected ITaskAttachmentRepository attachments;
  protected ITaskRepository tasks;

  this(ITaskAttachmentRepository attachments, ITaskRepository tasks) {
    this.attachments = attachments;
    this.tasks = tasks;
  }

  TaskAttachment[] listTaskAttachments(TenantId tenantId) {
    return attachments.findAll(tenantId);
  }

  TaskAttachment getTaskAttachment(TenantId tenantId, TaskAttachmentId id) {
    return attachments.findById(tenantId, id).required("Attachment '" ~ id.value ~ "'");
  }

  TaskAttachment createTaskAttachment(CreateTaskAttachmentRequest r) {
    auto task = tasks.findById(r.tenantId, TaskId(r.taskId.strip)).required("Task '" ~ r.taskId ~ "'");
    TaskAttachment a;
    stampCreated!(TaskAttachment, TaskAttachmentId)(a, r.tenantId, r.actor, r.id);
    if (attachments.existsById(r.tenantId, a.id))
      throw TaskCenterException.conflict("Attachment '" ~ a.id.value ~ "' already exists");
    a.taskId = task.id;
    a.fileName = r.fileName.strip;
    a.fileSize = r.fileSize;
    a.mimeType = r.mimeType.length > 0 ? r.mimeType : "application/octet-stream";
    a.url = r.url.strip;
    a.status = parseDomainEnumOr!AttachmentStatus(r.status, AttachmentStatus.available, "status");
    a.uploadedBy = r.actor.value;
    a.validate();
    attachments.save(a);
    return a;
  }

  TaskAttachment updateTaskAttachment(UpdateTaskAttachmentRequest r) {
    auto a = getTaskAttachment(r.tenantId, r.id);
    r.fileName.applyTo(a.fileName);
    r.mimeType.applyTo(a.mimeType);
    r.url.applyTo(a.url);
    applyEnum(r.status, a.status, "status");
    a.validate();
    stampUpdated(a, r.actor);
    attachments.save(a);
    return a;
  }

  void deleteTaskAttachment(TenantId tenantId, TaskAttachmentId id) {
    getTaskAttachment(tenantId, id);
    attachments.removeById(tenantId, id);
  }
}

/// Only the owner or a privileged caller may change a personal resource.
void requireOwner(string owner, UserId actor, bool privileged, string what) {
  if (!privileged && owner != actor.value)
    throw TaskCenterException.forbidden("Only " ~ owner ~ " may change this " ~ what);
}
