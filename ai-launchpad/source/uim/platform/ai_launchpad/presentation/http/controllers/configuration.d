/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.configuration;

// import uim.platform.ai_launchpad.application.usecases.manage.configurations;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ConfigurationController : PlatformController {
  private ManageConfigurationsUseCase configurations;

  this(ManageConfigurationsUseCase configurations) {
    this.configurations = configurations;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/configurations", &handleCreate);
    router.get("/api/v1/configurations", &handleList);
    router.get("/api/v1/configurations/*", &handleGet);
    router.delete_("/api/v1/configurations/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId();
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      CreateConfigurationRequest r;
      r.connectionId = connectionId;
      r.scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));
      r.inputArtifacts = jsonPairArray(j, "inputArtifacts");

      auto result = configurations.createConfiguration(tenantId, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Configuration created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId();
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      auto configs = scenarioId.isEmpty
        ? configurations.listConfigurations(tenantId, ScenarioId(scenarioId)) : configurations.listConfigurations(
          tenantId, connectionId);

      auto jarr = configs.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", configs.length)
        .set("resources", jarr)
        .set("message", "Configurations retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId();
      auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto c = configurations.getConfiguration(tenantId, connectionId, id);
      if (c.isNull) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = c.toJson.set("message", "Configuration retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId();
      auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = configurations.deleteConfiguration(tenantId, connectionId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("message", "Configuration deleted");

        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
