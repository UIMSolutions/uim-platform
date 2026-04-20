/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.entities.task_attachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskAttachment {
    mixin TenantEntity!(TaskAttachmentId);

    TaskId taskId;
    string fileName;
    string fileSize;
    string mimeType;
    AttachmentStatus status = AttachmentStatus.available;
    string uploadedBy;
    string uploadedAt;

    Json toJson() const {
        return entityToJson
            .set("taskId", taskId.value)
            .set("fileName", fileName)
            .set("fileSize", fileSize)
            .set("mimeType", mimeType)
            .set("status", status.toString())
            .set("uploadedBy", uploadedBy)
            .set("uploadedAt", uploadedAt);
    }
}
