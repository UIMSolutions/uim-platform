/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.scenario;

import uim.platform.ai_launchpad.application.usecases.manage.scenarios;
import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad.presentation.http.json_utils;

import uim.platform.ai_launchpad;

class ScenarioController : SAPController {
  private ManageScenariosUseCase uc;

  this(ManageScenariosUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/scenarios/sync", &handleSync);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGet);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  private void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      SyncScenarioRequest r;
      r.connectionId = connectionId;
      r.scenarioId = jsonStr(j, "scenarioId");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.labels = jsonStrArray(j, "labels");

      auto result = uc.sync(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Scenario synced");
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

      typeof(uc.listAll()) scenarios;
      if (connectionId.length > 0)
        scenarios = uc.listByConnection(connectionId);
      else
        scenarios = uc.listAll();

      auto jarr = Json.emptyArray;
      foreach (ref s; scenarios) {
        jarr ~= serializeScenario(s);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) scenarios.length);
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

      auto s = uc.get_(id, connectionId);
      if (s.id.length == 0) {
        writeError(res, 404, "Scenario not found");
        return;
      }

      res.writeJsonBody(serializeScenario(s), 200);
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

  private Json serializeScenario(Scenario s) {
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["connectionId"] = Json(s.connectionId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["labels"] = toJsonArray(s.labels);
    j["executionCount"] = Json(cast(long) s.executionCount);
    j["deploymentCount"] = Json(cast(long) s.deploymentCount);
    j["createdAt"] = Json(s.createdAt);
    j["modifiedAt"] = Json(s.modifiedAt);
    return j;
  }
}
