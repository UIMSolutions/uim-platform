/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.task_chain;

// import uim.platform.datasphere.application.usecases.manage.task_chains;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class TaskChainController : PlatformController {
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
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.scheduleExpression = j.getString("scheduleExpression");
      r.scheduleFrequency = j.getString("scheduleFrequency");

      auto now = Clock.currTime();
      // r.createdAt = now;
      // r.updatedAt = now;

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Task chain created");

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
      auto chains = uc.list(spaceId);

      auto jarr = Json.emptyArray;
      foreach (tc; chains) {
        jarr ~= Json.emptyObject
          .set("id", tc.id)
          .set("name", tc.name)
          .set("description", tc.description)
          .set("lastRunAt", tc.lastRunAt)
          .set("lastRunDurationMs", tc.lastRunDurationMs)
          .set("createdAt", tc.createdAt);
      }

      auto response = Json.emptyObject
        .set("count", Json(chains.length))
        .set("resources", jarr)
        .set("message", "Task chains retrieved successfully");
        
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = TaskChainId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto tc = uc.getById(id, spaceId);
      if (tc.id.isEmpty) {
        writeError(res, 404, "Task chain not found");
        return;
      }

      auto resp = Json.emptyObject
            .set("id", tc.id)
            .set("name", tc.name)
            .set("description", tc.description)
            .set("scheduleExpression", tc.scheduleExpression)
            .set("lastRunAt", tc.lastRunAt)
            .set("lastRunDurationMs", tc.lastRunDurationMs)
            .set("lastRunMessage", tc.lastRunMessage)
            .set("createdAt", tc.createdAt)
            .set("updatedAt", tc.updatedAt)
            .set("message", "Task chain retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = TaskChainId(extractIdFromPath(req.requestURI.to!string));
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

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
