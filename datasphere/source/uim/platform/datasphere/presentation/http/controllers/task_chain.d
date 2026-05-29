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

class TaskChainController : ManageController {
  private ManageTaskChainsUseCase usecase;

  this(ManageTaskChainsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/taskChains", &handleList);
    router.get("/api/v1/datasphere/taskChains/*", &handleGet);
    router.post("/api/v1/datasphere/taskChains", &handleCreate);
    router.delete_("/api/v1/datasphere/taskChains/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateTaskChainRequest r;
      r.tenantId = tenantId;
      r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.scheduleExpression = data.getString("scheduleExpression");
      r.scheduleFrequency = data.getString("scheduleFrequency");

      auto now = Clock.currTime();
      // r.createdAt = now;
      // r.updatedAt = now;

      auto result = usecase.createTaskChain(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Task chain created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      
      auto chains = usecase.listTaskChains(spaceId);
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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = TaskChainId(precheck.id);
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

      auto tc = usecase.getTaskChain(spaceId, id);
      if (tc.isNull) {
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

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
      auto id = TaskChainId(precheck.id);

      auto result = usecase.deleteTaskChain(tenantId, spaceId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
