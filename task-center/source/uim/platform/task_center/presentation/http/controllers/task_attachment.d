/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_attachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskAttachmentController : PlatformController {
    private ManageTaskAttachmentsUseCase usecase;

    this(ManageTaskAttachmentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/attachments", &handleList);
        router.get("/api/v1/task-center/attachments/*", &handleGet);
        router.post("/api/v1/task-center/attachments", &handleCreate);
        router.delete_("/api/v1/task-center/attachments/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateTaskAttachmentRequest r;
            r.tenantId = tenantId;
            r.taskAttachmentId = TaskAttachmentId(j.getString("id"));
            r.taskId = TaskId(j.getString("taskId"));
            r.fileName = j.getString("fileName");
            r.fileSize = j.getString("fileSize");
            r.mimeType = j.getString("mimeType");
            r.uploadedBy = UserId(j.getString("uploadedBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Attachment created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto taskId = TaskId(params.get("taskId", ""));

            TaskAttachment[] attachments = !taskId.isEmpty
                ? usecase.listTaskAttachments(tenantId, taskId) : [];

            auto jarr = attachments.map!(a => a.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", attachments.length)
                .set("resources", jarr)
                .set("message", "Attachment list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskAttachmentId(extractIdFromPath(req.requestURI.to!string));
            
            auto a = usecase.getById(tenantId, id);
            if (a.isNull) {
                writeError(res, 404, "Attachment not found");
                return;
            }
            res.writeJsonBody(toJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskAttachmentId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteTaskAttachment(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Attachment deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json attachmentToJson(TaskAttachment a) {
        return Json.emptyObject
            .set("id", a.id)
            .set("tenantId", a.tenantId)
            .set("taskId", a.taskId)
            .set("fileName", a.fileName)
            .set("fileSize", a.fileSize)
            .set("mimeType", a.mimeType)
            .set("status", a.status.to!string)
            .set("uploadedBy", a.uploadedBy)
            .set("uploadedAt", a.uploadedAt);
    }
}
