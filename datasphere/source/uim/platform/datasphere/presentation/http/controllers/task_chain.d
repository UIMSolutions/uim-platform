/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.task_chain;

import uim.platform.datasphere.application.usecases.manage.task_chains;
import uim.platform.datasphere.application.dto;
import uim.platform.datasphere.presentation.http.json_utils;

import uim.platform.datasphere;

class TaskChainController : SAPController {
  private ManageTaskChainsUseCase uc;

  this(ManageTaskChainsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/datasphere/taskChains", &handleList);
    router.get("/api/v1/datasphere/taskChains/*", &handleGet);
    router.post("/api/v1/datasphere/taskChains", &handleCreate);
    router.delete_("/api/v1/datasphere/taskChains/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateTaskChainRequest r;
      r.tenantId = req.getTenantId;
      r.spaceId = req.headers.get("X-Space-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.scheduleFrequency = j.getString("scheduleFrequency");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Task chain created");
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
      auto spaceId = req.headers.get("X-Space-Id", "");
      auto chains = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (ref tc; chains) {
        auto cj = Json.emptyObject;
        cj["id"] = Json(tc.id);
        cj["name"] = Json(tc.name);
        cj["description"] = Json(tc.description);
        cj["lastRunAt"] = Json(tc.lastRunAt);
        cj["lastRunDurationMs"] = Json(tc.lastRunDurationMs);
        cj["createdAt"] = Json(tc.createdAt);
        jarr ~= cj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) chains.length);
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

      auto tc = uc.get_(id, spaceId);
      if (tc.id.length == 0) {
        writeError(res, 404, "Task chain not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(tc.id);
      resp["name"] = Json(tc.name);
      resp["description"] = Json(tc.description);
      resp["scheduleExpression"] = Json(tc.scheduleExpression);
      resp["lastRunAt"] = Json(tc.lastRunAt);
      resp["lastRunDurationMs"] = Json(tc.lastRunDurationMs);
      resp["lastRunMessage"] = Json(tc.lastRunMessage);
      resp["createdAt"] = Json(tc.createdAt);
      resp["modifiedAt"] = Json(tc.modifiedAt);
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
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
