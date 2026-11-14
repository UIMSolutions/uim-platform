/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_attachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Maximum size of an attachment (metadata only; the file lives in a document store).
enum long maxAttachmentBytes = 25L * 1024 * 1024;

/// Metadata of a document attached to a task.
struct TaskAttachment {
  mixin TenantEntity!TaskAttachmentId;

  TaskId taskId;
  string fileName;
  long fileSize; /// bytes
  string mimeType;
  string url; /// where the content can be downloaded (document service, object store)
  AttachmentStatus status = AttachmentStatus.available;
  string uploadedBy;

  void validate() const {
    if (taskId.isNull)
      throw TaskCenterException.invalid("Attachment needs a taskId");
    requireText(fileName, "fileName");
    if (fileName.canFind('/') || fileName.canFind('\\'))
      throw TaskCenterException.invalid("fileName must not contain path separators");
    requireNonNegative(fileSize, "fileSize");
    if (fileSize > maxAttachmentBytes)
      throw TaskCenterException.invalid(format("Attachments are limited to %d MB", maxAttachmentBytes / (1024 * 1024)));
    if (url.length > 0 && !isHttpUrl(url))
      throw TaskCenterException.invalid("url must be an http(s) URL");
  }
}

///
unittest {
  TaskAttachment a;
  a.taskId = TaskId("t1");
  a.fileName = "invoice.pdf";
  a.fileSize = 1024;
  a.validate();
  a.fileName = "../etc/passwd";
  assert(failsWith(TaskCenterErrorKind.invalid, () { a.validate(); }));
  a.fileName = "big.iso";
  a.fileSize = maxAttachmentBytes + 1;
  assert(failsWith(TaskCenterErrorKind.invalid, () { a.validate(); }));
}
