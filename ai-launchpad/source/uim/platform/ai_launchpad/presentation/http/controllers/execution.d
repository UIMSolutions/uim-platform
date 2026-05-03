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
  private ManageExecutionsUseCase uc;

  this(ManageExecutionsUseCase uc) {
    this.uc = uc;
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      CreateExecutionRequest r;
      r.connectionId = connectionId;
      r.configurationId = j.getString("configurationId");
      r.resourceGroupId = j.getString("resourceGroupId");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution scheduled")
          .set("status", "PENDING");

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
      auto connectionId = req.headers.get("X-Connection-Id", "");
      auto scenarioId = req.headers.get("X-Scenario-Id", "");

      typeof(uc.listByConnection(connectionId)) executions;
      if (scenarioId.length > 0)
        executions = uc.listByScenario(scenarioId, connectionId);
      else
        executions = uc.listByConnection(connectionId);

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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      if (!uc.existsById(id, connectionId)) {
        writeError(res, 404, "Execution not found");
        return;
      }

      auto ex = uc.getById(id, connectionId);
      auto resp = ex.toJson
        .set("message", "Execution retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      PatchExecutionRequest r;
      r.connectionId = connectionId;
      r.executionId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Execution updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleBulkPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      BulkPatchExecutionRequest r;
      r.connectionId = connectionId;
      r.executionIds = getStringArray(j, "executionIds");
      r.targetStatus = j.getString("targetStatus");

      auto results = uc.bulkPatch(r);
      auto jarr = Json.emptyArray;
      foreach (result; results) {
        auto rj = Json.emptyObject
          .set("id", result.id)
          .set("success", result.success);
          
        if (result.error.length > 0)
          rj["error"] = Json(result.error);
        jarr ~= rj;
      }

      auto resp = Json.emptyObject
        .set("results", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto result = uc.remove(id, connectionId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeExecution(Execution ex) {
    import std.conv : to;
    import uim.platform.ai_launchpad.domain.entities.execution : OutputArtifact;

    auto artifacts = Json.emptyArray;
    foreach (a; ex.outputArtifacts) {
      artifacts ~= Json.emptyObject
        .set("name", a.name)
        .set("artifactId", a.artifactId)
        .set("artifactUrl", a.artifactUrl);
    }

    return Json.emptyObject
      .set("id", ex.id)
      .set("connectionId", ex.connectionId)
      .set("configurationId", ex.configurationId)
      .set("scenarioId", ex.scenarioId)
      .set("resourceGroupId", ex.resourceGroupId)
      .set("status", ex.status.to!string)
      .set("targetStatus", ex.targetStatus)
      .set("outputArtifacts", artifacts)
      .set("startedAt", ex.startedAt)
      .set("completedAt", ex.completedAt)
      .set("duration", ex.duration)
      .set("logsUrl", ex.logsUrl)
      .set("statusMessage", ex.statusMessage)
      .set("createdAt", ex.createdAt)
      .set("updatedAt", ex.updatedAt);
  }
}
