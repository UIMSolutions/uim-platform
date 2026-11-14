/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.dtos.collaboration;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct CreateTaskCommentRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  string taskId;
  string content;
}

struct UpdateTaskCommentRequest {
  TenantId tenantId;
  UserId actor;
  bool privileged;
  TaskCommentId id;
  Patch!string content;
}

struct CreateTaskAttachmentRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  string taskId;
  string fileName;
  long fileSize;
  string mimeType;
  string url;
  string status;
}

struct UpdateTaskAttachmentRequest {
  TenantId tenantId;
  UserId actor;
  TaskAttachmentId id;
  Patch!string fileName;
  Patch!string mimeType;
  Patch!string url;
  Patch!string status;
}
