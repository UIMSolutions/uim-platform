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
    private ManageTaskAttachmentsUseCase uc;

    this(ManageTaskAttachmentsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/task-center/attachments", &handleList);
        router.get("/api/v1/task-center/attachments/*", &handleGet);
        router.post("/api/v1/task-center/attachments", &handleCreate);
        router.delete_("/api/v1/task-center/attachments/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTaskAttachmentRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.taskId = j.getString("taskId");
            r.fileName = j.getString("fileName");
            r.fileSize = j.getString("fileSize");
            r.mimeType = j.getString("mimeType");
            r.uploadedBy = j.getString("uploadedBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Attachment created");
                res.writeJsonBody(resp, 201);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto taskId = params.get("taskId", "");

            TaskAttachment[] attachments;
            if (taskId.length > 0) {
                attachments = uc.listByTask(tenantId, taskId);
            } ) {
                attachments = [];
            }

            auto jarr = Json.emptyArray;
            foreach (ref a; attachments) {
                jarr ~= attachmentToJson(a);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) attachments.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto a = uc.get_(tenantId, id);
            if (a.id.isEmpty) {
                writeError(res, 404, "Attachment not found");
                return;
            }
            res.writeJsonBody(attachmentToJson(a), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Attachment deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json attachmentToJson(ref TaskAttachment a) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(a.id);
        j["tenantId"] = Json(a.tenantId);
        j["taskId"] = Json(a.taskId);
        j["fileName"] = Json(a.fileName);
        j["fileSize"] = Json(a.fileSize);
        j["mimeType"] = Json(a.mimeType);
        j["status"] = Json(a.status.to!string);
        j["uploadedBy"] = Json(a.uploadedBy);
        j["uploadedAt"] = Json(a.uploadedAt);
        return j;
    }
}
