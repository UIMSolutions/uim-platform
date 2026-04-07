/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.task;

import uim.platform.datasphere.application.usecases.manage.tasks;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class TaskController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.type = jsonStr(j, "type");
      r.targetObjectId = jsonStr(j, "targetObjectId");
      r.scheduleExpression = jsonStr(j, "scheduleExpression");
      r.scheduleFrequency = jsonStr(j, "scheduleFrequency");
      r.maxRetries = jsonInt(j, "maxRetries", 3);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Task created");
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = req.headers.get("X-Space-Id", "");
      auto tasks = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (ref t; tasks) {
        auto tj = Json.emptyObject;
        tj["id"] = Json(t.id);
        tj["name"] = Json(t.name);
        tj["description"] = Json(t.description);
        tj["targetObjectId"] = Json(t.targetObjectId);
        tj["lastRunDurationMs"] = Json(t.lastRunDurationMs);
        tj["createdAt"] = Json(t.createdAt);
        jarr ~= tj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) tasks.length);
      resp["resources"] = jarr;
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

      auto t = uc.get_(id, spaceId);
      if (t.id.length == 0) {
        writeError(res, 404, "Task not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(t.id);
      resp["name"] = Json(t.name);
      resp["description"] = Json(t.description);
      resp["targetObjectId"] = Json(t.targetObjectId);
      resp["scheduleExpression"] = Json(t.scheduleExpression);
      resp["startedAt"] = Json(t.startedAt);
      resp["completedAt"] = Json(t.completedAt);
      resp["lastRunDurationMs"] = Json(t.lastRunDurationMs);
      resp["lastRunMessage"] = Json(t.lastRunMessage);
      resp["retryCount"] = Json(cast(long) t.retryCount);
      resp["maxRetries"] = Json(cast(long) t.maxRetries);
      resp["createdAt"] = Json(t.createdAt);
      resp["modifiedAt"] = Json(t.modifiedAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto spaceId = req.headers.get("X-Space-Id", "");

      auto result = uc.remove(id, spaceId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
