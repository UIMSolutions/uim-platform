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

class TaskController : PlatformController {
  private ManageTasksUseCase uc;

  this(ManageTasksUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/tasks", &handleList);
    router.get("/api/v1/datasphere/tasks/*", &handleGet);
    router.post("/api/v1/datasphere/tasks", &handleCreate);
    router.delete_("/api/v1/datasphere/tasks/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTaskRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.targetObjectId = j.getString("targetObjectId");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.scheduleFrequency = j.getString("scheduleFrequency");
      r.maxRetries = j.getInteger("maxRetries", 3);

      auto now = Clock.currTime();
      r.createdAt = now;
      r.updatedAt = now;

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", Json("Task created"));

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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto tasks = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (t; tasks) {
        jarr ~= Json.emptyObject
          .set("id", t.id)
          .set("name", t.name)
          .set("description", t.description)
          .set("targetObjectId", t.targetObjectId)
          .set("lastRunDurationMs", t.lastRunDurationMs)
          .set("createdAt", t.createdAt);
      }

      auto resp = Json.emptyObject
        .set("count", tasks.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto t = uc.getById(id, spaceId);
      if (t.isNull) {
        writeError(res, 404, "Task not found");
        return;
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

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = TaskId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto result = uc.remove(spaceId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
