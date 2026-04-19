/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.task_attachments;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskAttachmentsUseCase { // TODO: UIMUseCase {
    private TaskAttachmentRepository repo;

    this(TaskAttachmentRepository repo) {
        this.repo = repo;
    }

    TaskAttachment getById(string tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    TaskAttachment[] listByTask(string tenantId, string taskId) {
        return repo.findByTask(tenantId, taskId);
    }

    CommandResult create(CreateTaskAttachmentRequest req) {
        TaskAttachment a;
        a.id = req.id;
        a.tenantId = req.tenantId;
        a.taskId = req.taskId;
        a.fileName = req.fileName;
        a.fileSize = req.fileSize;
        a.mimeType = req.mimeType;
        a.uploadedBy = req.uploadedBy;
        repo.save(req.tenantId, a);
        return CommandResult(true, req.id, "");
    }

    CommandResult remove(string tenantId, string id) {
        repo.remove(tenantId, id);
        return CommandResult(true, id.toString, "");
    }
}
