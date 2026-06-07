module uim.platform.workzone.presentation.http.controllers.task;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class TaskController : ManageHttpController {
  private ManageTasksUseCase useCase;

  this(ManageTasksUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/tasks", &handleList);
    router.get("/api/v1/tasks/*", &handleGet);
    router.post("/api/v1/tasks", &handleCreate);
    router.put("/api/v1/tasks/*", &handleUpdate);
    router.delete_("/api/v1/tasks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateTaskRequest r;
    r.tenantId = precheck.tenantId;
    r.assigneeId = UserId(data.getString("assigneeId"));
    r.assigneeName = data.getString("assigneeName");
    r.creatorId = UserId(data.getString("creatorId"));
    r.creatorName = data.getString("creatorName");
    r.title = data.getString("title");
    r.description = data.getString("description");
    r.priority = toTaskPriority(data.getString("priority", "medium"));
    r.sourceApp = data.getString("sourceApp");
    r.sourceTaskId = data.getString("sourceTaskId");
    r.actionUrl = data.getString("actionUrl");
    r.category = data.getString("category");
    r.dueDate = data.getLong("dueDate", 0);

    auto result = useCase.createTask(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Task created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    WZTask[] resources;
    auto assigneeId = req.query.get("assigneeId", "");
    auto status = req.query.get("status", "");
    if (assigneeId.length > 0)
      resources = useCase.listByAssignee(precheck.tenantId, UserId(assigneeId));
    else if (status.length > 0)
      resources = useCase.listByStatus(precheck.tenantId, toTaskStatus(status), UserId(""));
    else
      resources = useCase.listTasks(precheck.tenantId);

    auto payload = resources.map!(t => t.toJson()).array.toJson;

    return Json.emptyObject
      .set("count", resources.length)
      .set("resources", payload)
      .set("message", "Tasks retrieved successfully")
      .set("status", "success")
      .set("statusCode", 200);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getTask(precheck.tenantId, TaskId(precheck.id));
    if (entity.isNull)
      return errorResponse("Task not found", 404);

    return successResponse("Task retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    UpdateTaskRequest r;
    r.id = TaskId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.status = toTaskStatus(precheck.data.getString("status", "open"));
    r.priority = toTaskPriority(precheck.data.getString("priority", "medium"));
    r.title = precheck.data.getString("title");
    r.description = precheck.data.getString("description");
    r.dueDate = precheck.data.getLong("dueDate", 0);

    auto result = useCase.updateTask(r);
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Task updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteTask(precheck.tenantId, TaskId(precheck.id));
    if (!result.success)
      return errorResponse(result.message, 404);

    return successResponse("Task deleted successfully", "Deleted", 200, Json.emptyObject);
  }
}
