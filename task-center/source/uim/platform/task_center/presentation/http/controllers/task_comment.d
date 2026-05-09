/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task_comment;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskCommentController : PlatformController {
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateTaskCommentRequest r;
            r.tenantId = tenantId;
            r.taskCommentId = TaskCommentId(j.getString("id"));
            r.taskId = TaskId(j.getString("taskId"));
            r.author = j.getString("author");
            r.content = j.getString("content");

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto taskId = TaskId(params.get("taskId", ""));

            TaskComment[] comments = !taskId.isEmpty
                ? usecase.listCommentsByTask(tenantId, taskId) : [];    

            auto jarr = comments.map!(c => c.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", comments.length)
                .set("resources", jarr)
                .set("message", "Comment list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskCommentId(extractIdFromPath(req.requestURI.to!string));
            auto c = usecase.getById(tenantId, id);
            if (c.isNull) {
                writeError(res, 404, "Comment not found");
                return;
            }
            res.writeJsonBody(commentToJson(c), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = TaskCommentId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            UpdateTaskCommentRequest r;
            r.tenantId = tenantId;
            r.taskCommentId = id;
            r.content = j.getString("content");

            auto result = usecase.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskCommentId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteTaskComment(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Comment deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

}
