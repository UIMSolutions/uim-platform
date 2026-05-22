/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.execution;

// import uim.platform.ai_launchpad.application.usecases.manage.executions;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ExecutionController : PlatformController {
  private ManageExecutionsUseCase usecase;

  this(ManageExecutionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/executions", &handleCreate);
    router.get("/api/v1/executions", &handleList);
    router.get("/api/v1/executions/*", &handleGet);
    router.patch("/api/v1/executions/bulk", &handleBulkPatch);
    router.patch("/api/v1/executions/*", &handlePatch);
    router.delete_("/api/v1/executions/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      CreateExecutionRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.configurationId = j.getString("configurationId");
      r.resourceGroupId = j.getString("resourceGroupId");

      auto result = usecase.createExecution(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution scheduled")
          .set("status", "PENDING");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      auto executions = scenarioId.isEmpty 
        ? usecase.listExecutions(tenantId, connectionId) 
        : usecase.listExecutions(tenantId, connectionId, scenarioId);

      auto jarr = executions.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", executions.length)
        .set("resources", jarr)
        .set("message", "Executions retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto ex = usecase.getExecution(tenantId, connectionId, id);
      if (ex.isNull) {
        writeError(res, 404, "Execution not found");
        return;
      }

      auto resp = ex.toJson
        .set("message", "Execution retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      PatchExecutionRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.executionId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = usecase.patchExecution(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleBulkPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      BulkPatchExecutionRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.executionIds = getStrings(j, "executionIds").map!(s => ExecutionId(s)).array;
      r.targetStatus = j.getString("targetStatus");

      auto results = usecase.bulkPatchExecution(r);
      auto jarr = Json.emptyArray;
      foreach (result; results) {
        auto rj = Json.emptyObject
          .set("id", result.id)
          .set("success", result.success)
          .set("message", result.success ? "Execution updated" : "Failed to update execution"); 
          
        if (result.message.length > 0)
          rj["error"] = Json(result.message);
        jarr ~= rj;
      }

      auto resp = Json.emptyObject
        .set("results", jarr)
          .set("message", "Bulk update completed");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ExecutionId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = usecase.deleteExecution(tenantId, connectionId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Execution deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
