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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateTaskRequest r;
        r.tenantId = tenantId;
        r.id = precheck.id;
        r.taskDefinitionId = data.getString("taskDefinitionId");
        r.providerId = data.getString("providerId");
        r.externalTaskId = data.getString("externalTaskId");
        r.title = data.getString("title");
        r.description = data.getString("description");
        r.priority = data.getString("priority");
        r.category = data.getString("category");
        r.assignee = data.getString("assignee");
        r.creator = data.getString("creator");
        r.sourceApplication = data.getString("sourceApplication");
        r.dueDate = data.getString("dueDate");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.create(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
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

override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

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
}
 catch (Exception e) {
    writeError(res, 500, "Internal server error");
}
}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TaskId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid task ID", 400);

    auto path = precheck.path;
    if (pathEndsWithAction(path))
        return errorResponse("Not found", 404);

    auto t = usecase.getById(tenantId, id);
    if (t.isNull)
        return errorResponse("Task not found", 404);

    auto responseData = t.toJson();
    return successResponse("", 200, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TaskId(precheck.id);
    if (id.isNull)
        return errorResponse("Invalid task ID", 400);

    auto data = precheck.data;
    UpdateTaskRequest r;
    r.tenantId = tenantId;
    r.taskId = id;
    r.title = data.getString("title");
    r.description = data.getString("description");
    r.priority = data.getString("priority");
    r.assignee = data.getString("assignee");
    r.dueDate = data.getString("dueDate");
    r.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.updateTask(r);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Task updated successfully", 200, responseData);
}

protected Json claimHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto path = precheck.path;
    auto stripped = path[0 .. $ - 6]; // remove "/claim"
    auto id = TaskId(extractIdFromPath(stripped));
    if (id.isNull)
        return errorResponse("Invalid task ID", 400);

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto userId = data.getString("userId");

    auto result = usecase.claim(tenantId, id, userId);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Task claimed successfully", 200, resp);
}

protected void handleClaim(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto response = claimHandler(req);
        res.writeJsonBody(response, response.code);
    } catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}

protected Json releaseHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto path = precheck.path;
    auto stripped = path[0 .. $ - 8]; // remove "/release"
    auto id = TaskId(extractIdFromPath(stripped));
    if (id.isNull)
        return errorResponse("Invalid task ID", 400);

    auto tenantId = precheck.tenantId;

    auto result = usecase.releaseTask(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Task released successfully", 200, resp);
}

protected void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto response = releaseHandler(req);
        res.writeJsonBody(response, response.code);
    } catch (Exception e) {
        writeError(res, 500, "Internal server error");
    }
}

protected void handleForward(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 8]; // remove "/forward"
        auto id = TaskId(extractIdFromPath(stripped));
        auto data = precheck.data;
        auto toUser = data.getString("toUser");
        auto comment = data.getString("comment");

        auto result = usecase.forward(tenantId, id, toUser, comment);
        if (result.hasError)
            return errorResponse(result.message, 400);
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

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/complete"
        auto id = TaskId(extractIdFromPath(stripped));
        auto tenantId = precheck.tenantId;

        auto result = usecase.completeTask(tenantId, id)(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
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
        auto path = precheck.path;
        auto stripped = path[0 .. $ - 7]; // remove "/cancel"
        auto id = TaskId(extractIdFromPath(stripped));
        auto tenantId = precheck.tenantId;

        auto result = usecase.cancelTask(tenantId, id)(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
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

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TaskId(precheck.id);
    auto tenantId = precheck.tenantId;
    auto result = usecase.deleteTask(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);
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
