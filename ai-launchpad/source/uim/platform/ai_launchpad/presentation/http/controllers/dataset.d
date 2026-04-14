/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.dataset;

import uim.platform.ai_launchpad.application.usecases.manage.datasets;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class DatasetController : PlatformController {
  private ManageDatasetsUseCase uc;

  this(ManageDatasetsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/datasets", &handleRegister);
    router.get("/api/v1/datasets", &handleList);
    router.get("/api/v1/datasets/*", &handleGet);
    router.patch("/api/v1/datasets/*", &handlePatch);
    router.delete_("/api/v1/datasets/*", &handleDelete);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      RegisterDatasetRequest r;
      r.connectionId = connectionId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.scenarioId = j.getString("scenarioId");
      r.url = j.getString("url");
      r.size = jsonLong(j, "size");
      r.labels = getStringArray(j, "labels");

      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Dataset registered");
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

      typeof(uc.listByConnection(connectionId)) datasets;
      if (scenarioId.length > 0)
        datasets = uc.listByScenario(scenarioId, connectionId);
      else
        datasets = uc.listByConnection(connectionId);

      auto jarr = Json.datasets.map(ds => serializeDataset(d)).array.toJson;

      auto resp = Json.emptyObject
      .set("count", Json(datasets.length))
      .set("resources", jarr);

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

      auto d = uc.get_(id, connectionId);
      if (d.id.isEmpty) {
        writeError(res, 404, "Dataset not found");
        return;
      }

      res.writeJsonBody(serializeDataset(d), 200);
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

      PatchDatasetRequest r;
      r.connectionId = connectionId;
      r.datasetId = id;
      r.description = j.getString("description");
      r.status = j.getString("status");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["message"] = Json("Dataset updated");
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

  private Json serializeDataset(Dataset d) {
    import std.conv : to;
    return Json.emptyObject
      .set("id", d.id)
      .set("connectionId", d.connectionId)
      .set("name", d.name)
      .set("description", d.description)
      .set("scenarioId", d.scenarioId)
      .set("url", d.url)
      .set("size", d.size)
      .set("status", d.status.to!string)
      .set("labels", toJsonArray(d.labels))
      .set("createdAt", d.createdAt)
      .set("modifiedAt", d.modifiedAt);
  }
}
