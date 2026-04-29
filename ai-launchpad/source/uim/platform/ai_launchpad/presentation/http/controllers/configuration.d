/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.configuration;

import uim.platform.ai_launchpad.application.usecases.manage.configurations;
import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = req.headers.get("X-Connection-Id", "");

      CreateConfigurationRequest r;
      r.connectionId = connectionId;
      r.scenarioId = j.getString("scenarioId");
      r.executableId = j.getString("executableId");
      r.name = j.getString("name");
      r.parameterValues = jsonPairArray(j, "parameterValues");
      r.inputArtifacts = jsonPairArray(j, "inputArtifacts");

      auto result = configurations.create(r);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto connectionId = req.headers.get("X-Connection-Id", "");
      auto scenarioId = req.headers.get("X-Scenario-Id", "");

      typeof(configurations.listByConnection(connectionId)) configs;
      if (scenarioId.length > 0)
        configs = configurations.listByScenario(scenarioId, connectionId);
      else
        configs = configurations.listByConnection(connectionId);

      auto jarr = Json.emptyArray;
      foreach (c; configs) {
        jarr ~= serializeConfiguration(c);
      }

      auto resp = Json.emptyObject
        .set("count", configs.length)
        .set("resources", jarr)
        .set("message", "Configurations retrieved successfully");

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

      auto c = configurations.getById(id, connectionId);
      if (c.id.isEmpty) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      res.writeJsonBody(serializeConfiguration(c), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = req.headers.get("X-Connection-Id", "");

      auto result = configurations.remove(id, connectionId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeConfiguration(Configuration c) {
    import uim.platform.ai_launchpad.domain.entities.configuration : ParameterBinding, InputArtifactBinding;

    auto params = Json.emptyArray;
    foreach (p; c.parameters) {
      params ~= Json.emptyObject
        .set("key", p.key)
        .set("value", p.value);
    }

    auto artifacts = Json.emptyArray;
    foreach (a; c.inputArtifacts) {
      artifacts ~= Json.emptyObject
        .set("key", a.key)
        .set("artifactId", a.artifactId);
    }

    return Json.emptyObject
      .set("id", c.id)
      .set("connectionId", c.connectionId)
      .set("scenarioId", c.scenarioId)
      .set("executableId", c.executableId)
      .set("name", c.name)
      .set("parameters", params)
      .set("inputArtifacts", artifacts)
      .set("createdAt", Json(c.createdAt));
  }
}
