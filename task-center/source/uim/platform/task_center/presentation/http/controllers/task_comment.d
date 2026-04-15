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
    private ManageTaskCommentsUseCase uc;

    this(ManageTaskCommentsUseCase uc) {
        this.uc = uc;
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
            auto j = req.json;
            CreateTaskCommentRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.taskId = j.getString("taskId");
            r.author = j.getString("author");
            r.content = j.getString("content");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Comment created");
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
            TenantId tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto taskId = params.get("taskId", "");

            TaskComment[] comments;
            if (taskId.length > 0) {
                comments = uc.listByTask(tenantId, taskId);
            } else {
                comments = [];
            }

            auto jarr = Json.emptyArray;
            foreach (c; comments) {
                jarr ~= commentToJson(c);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(comments.length);
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
            auto c = uc.get_(tenantId, id);
            if (c.id.isEmpty) {
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
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateTaskCommentRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.content = j.getString("content");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Comment updated");
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
            import std.conv : to;
            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Comment deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private Json commentToJson(TaskComment c) {
        return Json.emptyObject
            .set("id", c.id)
            .set("tenantId", c.tenantId)
            .set("taskId", c.taskId)
            .set("author", c.author)
            .set("content", c.content)
            .set("createdAt", c.createdAt)
            .set("modifiedAt", c.modifiedAt);
    }
}
