/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.task;
// import uim.platform.process_automation.application.taskss.manage.tasks;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

class TaskController : ManageHttpController {
  private ManageTasksUseCase taskUsecase;

  this(ManageTasksUseCase taskUsecase) {
    this.taskUsecase = taskUsecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/process-automation/tasks", &handleList);
    router.get("/api/v1/process-automation/tasks/*", &handleGet);
    router.post("/api/v1/process-automation/tasks", &handleCreate);
    router.put("/api/v1/process-automation/tasks/*", &handleUpdate);
    router.post("/api/v1/process-automation/tasks/*/claim", &handleClaim);
    router.post("/api/v1/process-automation/tasks/*/complete", &handleComplete);
    router.delete_("/api/v1/process-automation/tasks/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateTaskRequest r;
    r.tenantId = tenantId;
    r.processInstanceId = data.getString("processInstanceId");
    r.taskId = precheck.id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.priority = data.getString("priority");
    r.assignee = data.getString("assignee");
    r.candidateUsers = data.getStrings("candidateUsers");
    r.candidateGroups = data.getStrings("candidateGroups");
    r.formId = data.getString("formId");
    r.dueDate = data.getString("dueDate");

    auto result = taskUsecase.createTask(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Task created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto results = taskUsecase.listTasks(tenantId);

    auto list = Json.emptyArray;
    foreach (t; results) {
      list ~= Json.emptyObject
        .set("id", t.id)
        .set("name", t.name)
        .set("type", t.type.to!string)
        .set("status", t.status.to!string)
        .set("priority", t.priority.to!string)
        .set("assignee", t.assignee)
        .set("processInstanceId", t.processInstanceId)
        .set("createdAt", t.createdAt)
        .set("dueDate", t.dueDate);
    }

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
    auto t = taskUsecase.getTask(tenantId, id);
    if (t.isNull)
      return errorResponse("Task not found", 404);

    auto resp = Json.emptyObject
      .set("id", t.id)
      .set("name", t.name)
      .set("description", t.description)
      .set("type", t.type.to!string)
      .set("status", t.status.to!string)
      .set("priority", t.priority.to!string)
      .set("assignee", t.assignee)
      .set("processInstanceId", t.processInstanceId)
      .set("formId", t.formId)
      .set("formData", t.formData)
      .set("candidateUsers", t.candidateUsers.map!(u => Json(u.value))
          .array.toJson)
      .set("candidateGroups", t.candidateGroups.map!(g => Json(g))
          .array.toJson)
      .set("completedBy", t.completedBy)
      .set("outcome", t.outcome)
      .set("createdAt", t.createdAt)
      .set("dueDate", t.dueDate)
      .set("completedAt", t.completedAt);

    return successResponse("Task retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateTaskRequest r;
    r.tenantId = tenantId;
    r.taskId = TaskId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.priority = data.getString("priority");
    r.assignee = data.getString("assignee");
    r.dueDate = data.getString("dueDate");

    auto result = taskUsecase.updateTask(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("TASK updated successfully", 200, responseData);
  }

  protected Json handleClaim(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto path = precheck.path;
    auto claimIdx = lastIndexOf(path, "/claim");
    if (claimIdx < 0) 
      return errorResponse("Invalid claim path", 400);

    auto sub = path[0 .. claimIdx];
    auto id = TaskId(extractIdFromPath(sub));

    auto data = precheck.data;
    ClaimTaskRequest r;
    r.tenantId = tenantId;
    r.taskId = id;
    r.userId = data.getString("userId");

    auto result = taskUsecase.claimTask(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Task claimed successfully", "Claimed", 200, resp);
  }

  mixin(HandleTemplate!("handleClaim", "claimHandler"));

  protected Json completeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

      import std.string : lastIndexOf;

      auto path = precheck.path;
      auto completeIdx = lastIndexOf(path, "/complete");
      if (completeIdx < 0) 
        return errorResponse("Invalid complete path", 400);
      
      auto sub = path[0 .. completeIdx];
      auto id = TaskId(extractIdFromPath(sub));

      auto data = precheck.data;
      CompleteTaskRequest r;
      r.tenantId = tenantId;
      r.taskId = id;
      r.completedBy = UserId(data.getString("completedBy"));
      r.outcome = data.getString("outcome");
      r.formData = data.getString("formData");

      auto result = taskUsecase.completeTask(r);
      if (result.hasError)
        return errorResponse(result.message, 400);
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "PATask completed");

        return successResponse("Task completed successfully", "Completed", 200, resp);
  }

  mixin(HandleTemplate!("handleComplete", "completeHandler"));

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;

  auto id = TaskId(precheck.id);
  auto result = taskUsecase.deleteTask(tenantId, id);
  if (result.hasError)
    return errorResponse(result.message, 400);

  auto responseData = Json.emptyObject.set("id", result.id);
  return successResponse("TASK deleted successfully", 200, responseData);
}
}
