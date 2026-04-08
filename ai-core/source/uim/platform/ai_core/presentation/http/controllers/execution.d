/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.execution;

import uim.platform.ai_core.application.usecases.manage.executions;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ExecutionController : SAPController {
  private ManageExecutionsUseCase uc;

  this(ManageExecutionsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v2/lm/executions", &handleCreate);
    router.get("/api/v2/lm/executions", &handleList);
    router.get("/api/v2/lm/executions/*", &handleGet);
    router.patch_("/api/v2/lm/executions/*", &handlePatch);
    router.delete_("/api/v2/lm/executions/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateExecutionRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.configurationId = j.getString("configurationId");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Execution scheduled");
        resp["status"] = Json("PENDING");
        res.writeJsonBody(resp, 202);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto executions = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (ref ex; executions) {
        jarr ~= executionToJson(ex);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) executions.length);
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
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto ex = uc.get_(id, rgId);
      if (ex.id.isEmpty) {
        writeError(res, 404, "Execution not found");
        return;
      }

      res.writeJsonBody(executionToJson(ex), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      PatchExecutionRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.executionId = id;
      r.targetStatus = j.getString("targetStatus");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Execution modified");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto result = uc.remove(id, rgId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json executionToJson(ref Execution ex) {
    import std.conv : to;

    auto ej = Json.emptyObject;
    ej["id"] = Json(ex.id);
    ej["configurationId"] = Json(ex.configurationId);
    ej["scenarioId"] = Json(ex.scenarioId);
    ej["executableId"] = Json(ex.executableId);
    ej["status"] = Json(ex.status.to!string);
    ej["statusMessage"] = Json(ex.statusMessage);
    ej["createdAt"] = Json(ex.createdAt);
    ej["modifiedAt"] = Json(ex.modifiedAt);
    ej["startedAt"] = Json(ex.startedAt);
    ej["completedAt"] = Json(ex.completedAt);
    return ej;
  }
}
