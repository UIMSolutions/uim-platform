/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.model;

import uim.platform.ai_launchpad.application.usecases.manage.models;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ModelController : PlatformController {
  private ManageModelsUseCase uc;

  this(ManageModelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/models", &handleRegister);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGet);
    router.patch("/api/v1/models/*", &handlePatch);
    router.delete_("/api/v1/models/*", &handleDelete);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      RegisterModelRequest r;
      r.connectionId = connectionId;
      r.name = j.getString("name");
      r.version_ = j.getString("version");
      r.description = j.getString("description");
      r.scenarioId = j.getString("scenarioId");
      r.executionId = j.getString("executionId");
      r.url = j.getString("url");
      r.size = jsonLong(j, "size");
      r.labels = jsonStrArray(j, "labels");

      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Model registered");
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

      typeof(uc.listByConnection(connectionId)) models;
      if (scenarioId.length > 0)
        models = uc.listByScenario(scenarioId, connectionId);
      else
        models = uc.listByConnection(connectionId);

      auto jarr = Json.emptyArray;
      foreach (m; models) {
        jarr ~= serializeModel(m);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(models.length);
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
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto m = uc.get_(id, connectionId);
      if (m.id.isEmpty) {
        writeError(res, 404, "Model not found");
        return;
      }

      res.writeJsonBody(serializeModel(m), 200);
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

      PatchModelRequest r;
      r.connectionId = connectionId;
      r.modelId = id;
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Model updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
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

  private Json serializeModel(Model m) {
    import std.conv : to;

    auto j = Json.emptyObject;
    j["id"] = Json(m.id);
    j["connectionId"] = Json(m.connectionId);
    j["name"] = Json(m.name);
    j["version"] = Json(m.version_);
    j["description"] = Json(m.description);
    j["scenarioId"] = Json(m.scenarioId);
    j["executionId"] = Json(m.executionId);
    j["url"] = Json(m.url);
    j["size"] = Json(m.size);
    j["status"] = Json(m.status.to!string);
    j["labels"] = toJsonArray(m.labels);
    j["createdAt"] = Json(m.createdAt);
    j["modifiedAt"] = Json(m.modifiedAt);
    return j;
  }
}
