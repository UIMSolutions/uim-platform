/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskController : ManageController {
    private ManageTasksUseCase usecase;

    this(ManageTasksUseCase usecase) {
        this.usecase = usecase;
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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateTaskRequest r;
            r.tenantId = tenantId;
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
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task created");

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
            auto assignee = params.get("assignee", "");
            auto status = params.get("status", "");
            auto providerId = params.get("providerId", "");

            Task[] tasks;
            if (!assignee.isEmpty) {
                tasks = usecase.listTasks(tenantId, assignee);
            } else if (!status.isEmpty) {
                tasks = usecase.listTasks(tenantId, status.to!TaskStatus);
            } else if (!providerId.isEmpty) {
                tasks = usecase.listTasks(tenantId, providerId);
            } else {
                tasks = usecase.listTasks(tenantId);
            }

            auto jarr = tasks.map!(t => toJson(t)).array.toJson;

            auto resp = Json.emptyObject
                .set("count", tasks.length)
                .set("resources", jarr)
                .set("message", "Tasks retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = req.requestURI.to!string;
            if (pathEndsWithAction(path))
                return;

            auto tenantId = req.getTenantId;
            auto id = TaskId(extractIdFromPath(path));
            auto t = usecase.getById(tenantId, id);
            if (t.isNull) {
                writeError(res, 404, "Task not found");
                return;
            }
            res.writeJsonBody(toJson(t), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = TaskId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;
            UpdateTaskRequest r;
            r.tenantId = tenantId;
            r.taskId = id;
            r.title = j.getString("title");
            r.description = j.getString("description");
            r.priority = j.getString("priority");
            r.assignee = j.getString("assignee");
            r.dueDate = j.getString("dueDate");
            r.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateTask(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
                auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 6]; // remove "/claim"
            auto id = TaskId(extractIdFromPath(stripped));
            auto tenantId = req.getTenantId;
            auto j = req.json;
            auto userId = j.getString("userId");

            auto result = usecase.claim(tenantId, id, userId);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task claimed");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/release"
            auto id = TaskId(extractIdFromPath(stripped));
            auto tenantId = req.getTenantId;

            auto result = usecase.releaseTask(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task released");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleForward(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 8]; // remove "/forward"
            auto id = TaskId(extractIdFromPath(stripped));
            auto j = req.json;
            auto toUser = j.getString("toUser");
            auto comment = j.getString("comment");

            auto result = usecase.forward(tenantId, id, toUser, comment);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task forwarded");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            

            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 9]; // remove "/complete"
            auto id = TaskId(extractIdFromPath(stripped));
            auto tenantId = req.getTenantId;

            auto result = usecase.completeTask(tenantId, id)(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task completed");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = req.requestURI.to!string;
            auto stripped = path[0 .. $ - 7]; // remove "/cancel"
            auto id = TaskId(extractIdFromPath(stripped));
            auto tenantId = req.getTenantId;

            auto result = usecase.cancelTask(tenantId, id)(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task cancelled");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = TaskId(extractIdFromPath(req.requestURI.to!string));
            auto tenantId = req.getTenantId;
            auto result = usecase.deleteTask(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Task deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
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
