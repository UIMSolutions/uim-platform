/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_comment;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class TaskCommentController : ManageHttpController {
    private ManageTaskCommentsUseCase usecase;

    this(ManageTaskCommentsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/task-center/comments", &handleList);
        router.get("/api/v1/task-center/comments/*", &handleGet);
        router.post("/api/v1/task-center/comments", &handleCreate);
        router.put("/api/v1/task-center/comments/*", &handleUpdate);
        router.delete_("/api/v1/task-center/comments/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTaskCommentRequest r;
        r.tenantId = tenantId;
        r.commentId = TaskCommentId(precheck.id);
        r.taskId = TaskId(data.getString("taskId"));
        r.author = data.getString("author");
        r.content = data.getString("content");

        auto result = usecase.createComment(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Comment created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto query = precheck.query;
        auto taskId = TaskId(query.get("taskId", ""));

        TaskComment[] comments = !taskId.isEmpty
            ? usecase.listComments(tenantId, taskId) : [];

        auto jarr = comments.map!(c => c.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", comments.length)
            .set("resources", jarr);

        return successResponse("Comment list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskCommentId(precheck.id);
        auto c = usecase.getComment(tenantId, id);
        if (c.isNull)
            return errorResponse("Comment not found", 404);

        return successResponse("Comment retrieved successfully", "Retrieved", 200, c.toJson);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskCommentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid comment ID", 400);

        auto data = precheck.data;
        UpdateTaskCommentRequest r;
        r.tenantId = tenantId;
        r.commentId = id;
        r.content = data.getString("content");

        auto result = usecase.updateComment(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Comment updated successfully", "Updated", 200, resp);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskCommentId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid comment ID", 400);

        auto result = usecase.deleteComment(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Comment deleted successfully", "Deleted", 200, resp);
    }
}
