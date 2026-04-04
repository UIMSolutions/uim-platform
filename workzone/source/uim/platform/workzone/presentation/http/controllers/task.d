/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.task;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage_tasks;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.task;
import uim.platform.identity_authentication.presentation.http.json_utils;

class TaskController
{
  private ManageTasksUseCase useCase;

  this(ManageTasksUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/tasks", &handleCreate);
    router.get("/api/v1/tasks", &handleList);
    router.get("/api/v1/tasks/*", &handleGet);
    router.put("/api/v1/tasks/*", &handleUpdate);
    router.post("/api/v1/tasks/complete/*", &handleComplete);
    router.delete_("/api/v1/tasks/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateTaskRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.assigneeId = j.getString("assigneeId");
      r.assigneeName = j.getString("assigneeName");
      r.creatorId = j.getString("creatorId");
      r.creatorName = j.getString("creatorName");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.sourceApp = j.getString("sourceApp");
      r.sourceTaskId = j.getString("sourceTaskId");
      r.actionUrl = j.getString("actionUrl");
      r.category = j.getString("category");
      r.tags = jsonStrArray(j, "tags");
      r.dueDate = jsonLong(j, "dueDate");

      auto pStr = j.getString("priority");
      if (pStr == "low")
        r.priority = TaskPriority.low;
      else if (pStr == "high")
        r.priority = TaskPriority.high;
      else if (pStr == "veryHigh")
        r.priority = TaskPriority.veryHigh;
      else
        r.priority = TaskPriority.medium;

      auto result = useCase.createTask(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto assigneeId = req.params.get("assigneeId", "");
      auto tasks = useCase.listByAssignee(assigneeId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref t; tasks)
        arr ~= serializeTask(t);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) tasks.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto t = useCase.getTask(id, tenantId);
      if (t is null)
      {
        writeError(res, 404, "Task not found");
        return;
      }
      res.writeJsonBody(serializeTask(*t), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = UpdateTaskRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.description = j.getString("description");
      r.dueDate = jsonLong(j, "dueDate");

      auto sStr = j.getString("status");
      if (sStr == "inProgress")
        r.status = TaskStatus.inProgress;
      else if (sStr == "completed")
        r.status = TaskStatus.completed;
      else if (sStr == "cancelled")
        r.status = TaskStatus.cancelled;
      else
        r.status = TaskStatus.open;

      auto pStr = j.getString("priority");
      if (pStr == "low")
        r.priority = TaskPriority.low;
      else if (pStr == "high")
        r.priority = TaskPriority.high;
      else if (pStr == "veryHigh")
        r.priority = TaskPriority.veryHigh;
      else
        r.priority = TaskPriority.medium;

      auto result = useCase.updateTask(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("updated");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleComplete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.completeTask(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("completed");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      useCase.deleteTask(id, tenantId);
      res.writeBody("", 204);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeTask(ref Task t)
{
  // import std.conv : to;
  auto j = Json.emptyObject;
  j["id"] = Json(t.id);
  j["tenantId"] = Json(t.tenantId);
  j["assigneeId"] = Json(t.assigneeId);
  j["assigneeName"] = Json(t.assigneeName);
  j["creatorId"] = Json(t.creatorId);
  j["creatorName"] = Json(t.creatorName);
  j["title"] = Json(t.title);
  j["description"] = Json(t.description);
  j["status"] = Json(t.status.to!string);
  j["priority"] = Json(t.priority.to!string);
  j["sourceApp"] = Json(t.sourceApp);
  j["sourceTaskId"] = Json(t.sourceTaskId);
  j["actionUrl"] = Json(t.actionUrl);
  j["category"] = Json(t.category);
  j["dueDate"] = Json(t.dueDate);
  j["completedAt"] = Json(t.completedAt);
  j["createdAt"] = Json(t.createdAt);
  j["updatedAt"] = Json(t.updatedAt);

  auto tags = Json.emptyArray;
  foreach (ref tag; t.tags)
    tags ~= Json(tag);
  j["tags"] = tags;

  return j;
}
