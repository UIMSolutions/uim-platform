/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.scenario;

import uim.platform.ai_launchpad.application.usecases.manage.scenarios;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

class ScenarioController : PlatformController {
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
      r.scenarioId = j.getString("scenarioId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.labels = getStringArray(j, "labels");

      auto result = uc.sync(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario synced");

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
      foreach (s; scenarios) {
        jarr ~= serializeScenario(s);
      }

      auto resp = Json.emptyObject
        .set("count", scenarios.length)
        .set("resources", jarr)
        .set("message", "Scenarios retrieved successfully");
        
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

      auto s = uc.getById(id, connectionId);
      if (s.isNull) {
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
    return Json.emptyObject
      .set("id", s.id)
      .set("connectionId", s.connectionId)
      .set("name", s.name)
      .set("description", s.description)
      .set("labels", toJsonArray(s.labels))
      .set("executionCount", s.executionCount)
      .set("deploymentCount", s.deploymentCount)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt);
  }
}
