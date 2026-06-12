/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.task_attachments;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageTaskAttachmentsUseCase { // TODO: UIMUseCase {
    private TaskAttachmentRepository repo;

    this(TaskAttachmentRepository repo) {
        this.repo = repo;
    }

    TaskAttachment getTaskAttachmentById(TenantId tenantId, TaskAttachmentId id) {
        return repo.findById(tenantId, id);
    }

    TaskAttachment[] listTaskAttachmentsByTask(TenantId tenantId, TaskId taskId) {
        return repo.findByTask(tenantId, taskId);
    }

    CommandResult createTaskAttachment(CreateTaskAttachmentRequest req) {
        TaskAttachment attachment;
        attachment.initEntity(req.tenantId);

        attachment.id = req.attachmentId;
        attachment.taskId = req.taskId;
        attachment.fileName = req.fileName;
        attachment.fileSize = req.fileSize;
        attachment.mimeType = req.mimeType;
        attachment.uploadedBy = req.uploadedBy;

        repo.save(attachment);
        return CommandResult(true, attachment.id.value, "");
    }

    CommandResult deleteTaskAttachment(TenantId tenantId, TaskAttachmentId id) {
        auto attachment = repo.findById(tenantId, id);
        if (attachment.isNull)
            return CommandResult(false, "", "Task attachment not found");

        repo.remove(attachment);
        return CommandResult(true, attachment.id.value, "");
    }
}
