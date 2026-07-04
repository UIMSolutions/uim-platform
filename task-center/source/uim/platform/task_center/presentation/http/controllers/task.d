/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.presentation.http.controllers.task;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class TaskController : ManageHttpController {
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
        CreateTaskRequest request;
        request.tenantId = tenantId;
        request.taskId = precheck.id;
        request.definitionId = data.getString("taskDefinitionId");
        request.providerId = data.getString("providerId");
        request.externalTaskId = data.getString("externalTaskId");
        request.title = data.getString("title");
        request.description = data.getString("description");
        request.priority = data.getString("priority");
        request.category = data.getString("category");
        request.assignee = data.getString("assignee");
        request.creator = data.getString("creator");
        request.sourceApplication = data.getString("sourceApplication");
        request.dueDate = data.getString("dueDate");
        request.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createTask(request);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto query = precheck.query;
        auto assignee = query.get("assignee", "");
        auto status = query.get("status", "");
        auto providerId = query.get("providerId", "");

        UIMTask[] tasks;
        if (!assignee.isEmpty) {
            tasks = usecase.listTasks(tenantId, assignee);
        } else if (!status.isEmpty) {
            tasks = usecase.listTasks(tenantId, status.to!TaskStatus);
        } else if (!providerId.isEmpty) {
            tasks = usecase.listTasks(tenantId, providerId);
        } else {
            tasks = usecase.listTasks(tenantId);
        }

        auto jarr = tasks.map!(t => t.toJson).array.toJson;

        auto resp = Json.emptyObject
            .set("count", tasks.length)
            .set("resources", jarr);

        return successResponse("Tasks retrieved successfully", "Retrieved", 200, resp);
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

        auto t = usecase.getTask(tenantId, id);
        if (t.isNull)
            return errorResponse("Task not found", 404);

        auto responseData = t.toJson();
        return successResponse("Task retrieved successfully", "Retrieved", 200, responseData);
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
        UpdateTaskRequest request;
        request.tenantId = tenantId;
        request.taskId = id;
        request.title = data.getString("title");
        request.description = data.getString("description");
        request.priority = data.getString("priority");
        request.assignee = data.getString("assignee");
        request.dueDate = data.getString("dueDate");
        request.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateTask(request);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Task updated successfully", "Updated", 200, responseData);
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
        auto userId = UserId(data.getString("userId"));

        auto result = usecase.claimTask(tenantId, id, userId);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task claimed successfully", "Claimed", 200, resp);
    }

    mixin(HandleTemplate!("handleClaim", "claimHandler"));

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
        return successResponse("Task released successfully", "Released", 200, resp);
    }

    mixin(HandleTemplate!("handleRelease", "releaseHandler"));

    protected Json forwardHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 8]; // remove "/forward"
        auto tenantId = precheck.tenantId;
        auto id = TaskId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid task ID", 400);

        auto data = precheck.data;
        auto toUser = UserId(data.getString("toUser"));
        auto comment = data.getString("comment");

        auto result = usecase.forwardTask(tenantId, id, toUser, comment);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task forwarded successfully", "Forwarded", 200, resp);
    }

    mixin(HandleTemplate!("handleForward", "forwardHandler"));

    protected Json completeHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 9]; // remove "/complete"
        auto id = TaskId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid task ID", 400);

        auto tenantId = precheck.tenantId;

        auto result = usecase.completeTask(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task completed");

        return successResponse("Task completed successfully", "Completed", 200, resp);
    }

    mixin(HandleTemplate!("handleComplete", "completeHandler"));

    protected Json cancelHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto path = precheck.path;
        auto stripped = path[0 .. $ - 7]; // remove "/cancel"

        auto tenantId = precheck.tenantId;
        auto id = TaskId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid task ID", 400);

        auto result = usecase.cancelTask(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task cancelled successfully", "Cancelled", 200, resp);
    }

    mixin(HandleTemplate!("handleCancel", "cancelHandler"));

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = TaskId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid task ID", 400);

        auto result = usecase.deleteTask(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Task deleted successfully", "Deleted", 200, resp);
}

private bool pathEndsWithAction(string path) {
    import std.algorithm : endsWith;

    return path.endsWith("/claim") || path.endsWith("/release") ||
        path.endsWith(
            "/forward") || path.endsWith("/complete") ||
        path.endsWith("/cancel");
}
}
