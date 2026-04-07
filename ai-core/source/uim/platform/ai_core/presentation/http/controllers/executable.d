/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.executable;

import uim.platform.ai_core.application.usecases.manage.executables;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ExecutableController : SAPController {
  private ManageExecutablesUseCase uc;

  this(ManageExecutablesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v2/lm/executables", &handleList);
    router.get("/api/v2/lm/executables/*", &handleGet);
    router.post("/api/v2/lm/executables", &handleCreate);
    router.delete_("/api/v2/lm/executables/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateExecutableRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.scenarioId = j.getString("scenarioId");
      r.id = j.getString("id");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.type = j.getString("type");
      r.versionId = j.getString("versionId");
      r.deployable = j.getString("deployable");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Executable registered");
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
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto scenarioId = req.params.get("scenarioId", "");

      typeof(uc.list(rgId)) executables;
      if (scenarioId.length > 0)
        executables = uc.listByScenario(scenarioId, rgId);
      else
        executables = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (ref e; executables) {
        auto ej = Json.emptyObject;
        ej["id"] = Json(e.id);
        ej["scenarioId"] = Json(e.scenarioId);
        ej["name"] = Json(e.name);
        ej["description"] = Json(e.description);
        ej["type"] = Json(e.type == ExecutableType.serving ? "serving" : "workflow");
        ej["versionId"] = Json(e.versionId);
        ej["deployable"] = Json(e.deployable);
        ej["createdAt"] = Json(e.createdAt);
        ej["modifiedAt"] = Json(e.modifiedAt);
        jarr ~= ej;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) executables.length);
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

      auto e = uc.get_(id, rgId);
      if (e.id.length == 0) {
        writeError(res, 404, "Executable not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(e.id);
      resp["scenarioId"] = Json(e.scenarioId);
      resp["name"] = Json(e.name);
      resp["description"] = Json(e.description);
      resp["type"] = Json(e.type == ExecutableType.serving ? "serving" : "workflow");
      resp["versionId"] = Json(e.versionId);
      resp["deployable"] = Json(e.deployable);
      resp["createdAt"] = Json(e.createdAt);
      resp["modifiedAt"] = Json(e.modifiedAt);
      res.writeJsonBody(resp, 200);
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
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
