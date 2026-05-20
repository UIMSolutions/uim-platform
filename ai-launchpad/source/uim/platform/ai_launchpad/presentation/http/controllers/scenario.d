/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.scenario;

// import uim.platform.ai_launchpad.application.usecases.manage.scenarios;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ScenarioController : PlatformController {
  private ManageScenariosUseCase usecase;

  this(ManageScenariosUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/scenarios/sync", &handleSync);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGet);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  protected void handleSync(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      SyncScenarioRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.scenarioId = ScenarioId(j.getString("scenarioId"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.labels = getStrings(j, "labels");

      auto result = usecase.syncScenario(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario synced");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto scenarios = connectionId.isEmpty
        ? usecase.listScenarios(tenantId) : usecase.listScenarios(tenantId, connectionId);

      auto jarr = scenarios.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", scenarios.length)
        .set("resources", jarr)
        .set("message", "Scenarios retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScenarioId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto s = usecase.getScenario(tenantId, connectionId, id);
      if (s.isNull) {
        writeError(res, 404, "Scenario not found");
        return;
      }

      auto resp = s.toJson
        .set("message", "Scenario retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScenarioId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = usecase.deleteScenario(tenantId, connectionId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario deleted successfully");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
