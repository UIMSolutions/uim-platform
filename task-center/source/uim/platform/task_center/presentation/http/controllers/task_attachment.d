/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_attachment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskAttachmentController : ManageController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTaskAttachmentRequest r;
        r.tenantId = tenantId;
        r.taskAttachmentId = TaskAttachmentId(precheck.id);
        r.taskId = TaskId(data.getString("taskId"));
        r.fileName = data.getString("fileName");
        r.fileSize = data.getString("fileSize");
        r.mimeType = data.getString("mimeType");
        r.uploadedBy = UserId(data.getString("uploadedBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Attachment created successfully", "Created", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto params = req.queryParams();
        auto taskId = TaskId(params.get("taskId", ""));

        TaskAttachment[] attachments = !taskId.isEmpty
            ? usecase.listTaskAttachments(tenantId, taskId) : [];

        auto list = attachments.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Attachment list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskAttachmentId(precheck.id);

        auto a = usecase.getById(tenantId, id);
        if (a.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = a.toJson();
        return successResponse("Attachment retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskAttachmentId(precheck.id);

        auto result = usecase.deleteTaskAttachment(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Attachment deleted successfully", "Deleted", 200, responseData);
    }
}
