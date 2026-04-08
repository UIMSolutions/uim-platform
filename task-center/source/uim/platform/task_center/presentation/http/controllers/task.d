/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskController : SAPController {
    private ManageTasksUseCase uc;

    this(ManageTasksUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/task-center/tasks", &handleList);
        router.get("/api/v1/task-center/tasks/*", &handleGet);
        router.post("/api/v1/task-center/tasks", &handleCreate);
        router.put("/api/v1/task-center/tasks/*", &handleUpdate);
        router.post("/api/v1/task-center/tasks/*/claim", &handleClaim);
        router.post("/api/v1/task-center/tasks/*/release", &handleRelease);
        router.post("/api/v1/task-center/tasks/*/forward", &handleForward);
        router.post("/api/v1/task-center/tasks/*/complete", &handleComplete);
        router.post("/api/v1/task-center/tasks/*/cancel", &handleCancel);
        router.delete_("/api/v1/task-center/tasks/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateTaskRequest r;
            r.tenantId = req.getTenantId;
            r.id = j.getString("id");
            r.taskDefinitionId = j.getString("taskDefinitionId");
            r.providerId = j.getString("providerId");
            r.externalTaskId = j.getString("externalTaskId");
            r.title = j.getString("title");
            r.description = j.getString("description");
            r.priority = j.getString("priority");
            r.category = j.getString("category");
            r.assignee = j.getString("assignee");
            r.creator = j.getString("creator");
            r.sourceApplication = j.getString("sourceApplication");
            r.dueDate = j.getString("dueDate");
            r.createdBy = j.getString("createdBy");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task created");
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
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto params = req.queryParams();
            auto assignee = params.get("assignee", "");
            auto status = params.get("status", "");
            auto providerId = params.get("providerId", "");

            Task[] tasks;
            if (assignee.length > 0) {
                tasks = uc.listByAssignee(tenantId, assignee);
            } else if (status.length > 0) {
                tasks = uc.listByStatus(tenantId, status.to!TaskStatus);
            } else if (providerId.length > 0) {
                tasks = uc.listByProvider(tenantId, providerId);
            } ) {
                tasks = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (ref t; tasks) {
                jarr ~= taskToJson(t);
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) tasks.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            if (pathEndsWithAction(path)) return;

            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto t = uc.get_(tenantId, id);
            if (t.id.length == 0) {
                writeError(res, 404, "Task not found");
                return;
            }
            res.writeJsonBody(taskToJson(t), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateTaskRequest r;
            r.tenantId = req.getTenantId;
            r.id = id;
            r.title = j.getString("title");
            r.description = j.getString("description");
            r.priority = j.getString("priority");
            r.assignee = j.getString("assignee");
            r.dueDate = j.getString("dueDate");
            r.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/claim"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;
            auto j = req.json;
            auto userId = j.getString("userId");

            auto result = uc.claim(tenantId, id, userId);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task claimed");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/release"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;

            auto result = uc.release(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task released");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleForward(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/forward"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;
            auto j = req.json;
            auto toUser = j.getString("toUser");
            auto comment = j.getString("comment");

            auto result = uc.forward(tenantId, id, toUser, comment);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task forwarded");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/complete"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;

            auto result = uc.complete(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task completed");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 7]; // remove "/cancel"
            auto id = extractIdFromPath(stripped);
            auto tenantId = req.getTenantId;

            auto result = uc.cancel(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task cancelled");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto tenantId = req.getTenantId;
            auto result = uc.remove(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Task deleted");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private bool pathEndsWithAction(string path) {
        import std.algorithm : endsWith;
        return path.endsWith("/claim") || path.endsWith("/release") ||
               path.endsWith("/forward") || path.endsWith("/complete") ||
               path.endsWith("/cancel");
    }

    private Json taskToJson(ref Task t) {
        import std.conv : to;
        auto j = Json.emptyObject;
        j["id"] = Json(t.id);
        j["tenantId"] = Json(t.tenantId);
        j["taskDefinitionId"] = Json(t.taskDefinitionId);
        j["providerId"] = Json(t.providerId);
        j["externalTaskId"] = Json(t.externalTaskId);
        j["title"] = Json(t.title);
        j["description"] = Json(t.description);
        j["status"] = Json(t.status.to!string);
        j["priority"] = Json(t.priority.to!string);
        j["category"] = Json(t.category.to!string);
        j["assignee"] = Json(t.assignee);
        j["creator"] = Json(t.creator);
        j["processor"] = Json(t.processor);
        j["sourceApplication"] = Json(t.sourceApplication);
        j["isClaimed"] = Json(t.isClaimed);
        j["claimedBy"] = Json(t.claimedBy);
        j["dueDate"] = Json(t.dueDate);
        j["completedAt"] = Json(t.completedAt);
        j["createdBy"] = Json(t.createdBy);
        j["createdAt"] = Json(t.createdAt);
        return j;
    }
}
