/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.scenario;
// import uim.platform.ai_core.application.usecases.manage.scenarios;
// import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ScenarioController : ManageController {
  private ManageScenariosUseCase usecase;

  this(ManageScenariosUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v2/lm/scenarios", &handleList);
    router.get("/api/v2/lm/scenarios/*", &handleGet);
    router.post("/api/v2/lm/scenarios", &handleCreate);
    router.delete_("/api/v2/lm/scenarios/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto j = req.json;

      CreateScenarioRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = rgId;
      r.scenarioId = ScenarioId(j.getString("id"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.labels = getStrings(j, "labels");

      auto result = usecase.createScenario(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Scenario registered");

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
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto scenarios = usecase.listScenarios(tenantId, rgId);

      auto jarr = Json.emptyArray;
      foreach (s; scenarios) {
        jarr ~= Json.emptyObject
          .set("id", s.id)
          .set("name", s.name)
          .set("description", s.description)
          .set("labels", s.labels.map!(label => label.toJson).array.toJson)
          .set("createdAt", s.createdAt)
          .set("updatedAt", s.updatedAt);
      }

      auto resp = Json.emptyObject
        .set("count", scenarios.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScenarioId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto s = usecase.getScenario(tenantId, rgId, id);
      if (s.isNull) {
        writeError(res, 404, "Scenario not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("labels", s.labels.map!(label => label.toJson).array.toJson)
        .set("createdAt", s.createdAt)
        .set("updatedAt", s.updatedAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ScenarioId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto result = usecase.deleteScenario(tenantId, rgId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
