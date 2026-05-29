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

class TaskController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
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
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto tasks = usecase.listTasks(tenantId, spaceId);
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
        .set("resources", jarr)
        .set("message", "Tasks retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = TaskId(precheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto t = usecase.getTaskById(tenantId, spaceId, id);
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

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto id = TaskId(precheck.id);

      auto result = usecase.deleteTask(tenantId, spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
          .set("message", "Task deleted successfully"); 
        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
