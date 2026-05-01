/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskController : PlatformController {
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
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task created");

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
            import std.conv : to;

            TenantId tenantId = req.getTenantId;
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
            } else {
                tasks = uc.list(tenantId);
            }

            auto jarr = Json.emptyArray;
            foreach (t; tasks) {
                jarr ~= taskToJson(t);
            }

            auto resp = Json.emptyObject
                .set("count", tasks.length)
                .set("resources", jarr)
                .set("message", "Tasks retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            if (pathEndsWithAction(path))
                return;

            TenantId tenantId = req.getTenantId;
            auto id = extractIdFromPath(path);
            auto t = uc.getById(tenantId, id);
            if (t.isNull) {
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
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task updated");

                res.writeJsonBody(resp, 200);
            } else {
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
            TenantId tenantId = req.getTenantId;
            auto j = req.json;
            auto userId = j.getString("userId");

            auto result = uc.claim(tenantId, id, userId);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task claimed");

                res.writeJsonBody(resp, 200);
            } else {
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
            TenantId tenantId = req.getTenantId;

            auto result = uc.release(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task released");

                res.writeJsonBody(resp, 200);
            } else {
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
            TenantId tenantId = req.getTenantId;
            auto j = req.json;
            auto toUser = j.getString("toUser");
            auto comment = j.getString("comment");

            auto result = uc.forward(tenantId, id, toUser, comment);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task forwarded");

                res.writeJsonBody(resp, 200);
            } else {
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
            TenantId tenantId = req.getTenantId;

            auto result = uc.complete(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task completed");

                res.writeJsonBody(resp, 200);
            } else {
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
            TenantId tenantId = req.getTenantId;

            auto result = uc.cancel(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task cancelled");

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

            auto id = extractIdFromPath(req.requestURI.to!string);
            TenantId tenantId = req.getTenantId;
            auto result = uc.removeById(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task deleted");

                res.writeJsonBody(resp, 200);
            } else {
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

    private Json taskToJson(Task t) {
        return Json.emptyObject
            .set("id", t.id)
            .set("tenantId", t.tenantId)
            .set("taskDefinitionId", t.taskDefinitionId)
            .set("providerId", t.providerId)
            .set("externalTaskId", t.externalTaskId)
            .set("title", t.title)
            .set("description", t.description)
            .set("status", t.status.to!string)
            .set("priority", t.priority.to!string)
            .set("category", t.category.to!string)
            .set("assignee", t.assignee)
            .set("creator", t.creator)
            .set("processor", t.processor)
            .set("sourceApplication", t.sourceApplication)
            .set("isClaimed", t.isClaimed)
            .set("claimedBy", t.claimedBy)
            .set("dueDate", t.dueDate)
            .set("completedAt", t.completedAt)
            .set("createdBy", t.createdBy)
            .set("createdAt", t.createdAt);
    }
}
