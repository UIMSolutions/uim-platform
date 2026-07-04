/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.task;
// import uim.platform.datasphere.application.usecases.manage.tasks;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class TaskController : ManageHttpController {
  private ManageTasksUseCase usecase;

  this(ManageTasksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/tasks", &handleList);
    router.get("/api/v1/datasphere/tasks/*", &handleGet);
    router.post("/api/v1/datasphere/tasks", &handleCreate);
    router.delete_("/api/v1/datasphere/tasks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateTaskRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.targetObjectId = data.getString("targetObjectId");
    r.scheduleExpression = data.getString("scheduleExpression");
    r.scheduleFrequency = data.getString("scheduleFrequency");
    r.maxRetries = data.getInteger("maxRetries", 3);

    auto now = Clock.currTime();
    // r.createdAt = now;
    // r.updatedAt = now;

    auto result = usecase.createTask(r);
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
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto tasks = usecase.listTasks(tenantId, spaceId);
    auto list = Json.emptyArray;
    foreach (t; tasks) {
      list ~= Json.emptyObject
        .set("id", t.id)
        .set("name", t.name)
        .set("description", t.description)
        .set("targetObjectId", t.targetObjectId)
        .set("lastRunDurationMs", t.lastRunDurationMs)
        .set("createdAt", t.createdAt);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Tasks retrieved successfully", "Retrieved", 200, responseData);

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TaskId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto t = usecase.getTaskById(tenantId, spaceId, id);
    if (t.isNull) {
      return errorResponse("Task not found", 404);
    }

    auto response = Json.emptyObject
      .set("id", t.id)
      .set("name", t.name)
      .set("description", t.description)
      .set("targetObjectId", t.targetObjectId)
      .set("scheduleExpression", t.scheduleExpression)
      .set("startedAt", t.startedAt)
      .set("completedAt", t.completedAt)
      .set("lastRunDurationMs", t.lastRunDurationMs)
      .set("lastRunMessage", t.lastRunMessage)
      .set("retryCount", t.retryCount)
      .set("maxRetries", t.maxRetries)
      .set("createdAt", t.createdAt)
      .set("updatedAt", t.updatedAt);

    return successResponse("Task retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto id = TaskId(precheck.id);

    auto result = usecase.deleteTask(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto response = Json.emptyObject.set("id", result.id);
    return successResponse("Task deleted successfully", "Deleted", 200, response);

  }
}
