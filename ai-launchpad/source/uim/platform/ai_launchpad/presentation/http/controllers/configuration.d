/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.configuration;

import uim.platform.ai_launchpad.application.usecases.manage.configurations;
import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad.presentation.http.json_utils;

import uim.platform.ai_launchpad;

class ConfigurationController : SAPController {
  private ManageConfigurationsUseCase uc;

  this(ManageConfigurationsUseCase uc) {
    this.uc = uc;
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
      r.scenarioId = jsonStr(j, "scenarioId");
      r.executableId = jsonStr(j, "executableId");
      r.name = jsonStr(j, "name");
      r.parameterValues = jsonPairArray(j, "parameterValues");
      r.inputArtifacts = jsonPairArray(j, "inputArtifacts");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Configuration created");
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

      typeof(uc.listByConnection(connectionId)) configs;
      if (scenarioId.length > 0)
        configs = uc.listByScenario(scenarioId, connectionId);
      else
        configs = uc.listByConnection(connectionId);

      auto jarr = Json.emptyArray;
      foreach (ref c; configs) {
        jarr ~= serializeConfiguration(c);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) configs.length);
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

      auto c = uc.get_(id, connectionId);
      if (c.id.length == 0) {
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

  private Json serializeConfiguration(Configuration c) {
    import uim.platform.ai_launchpad.domain.entities.configuration : ParameterBinding, InputArtifactBinding;
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["connectionId"] = Json(c.connectionId);
    j["scenarioId"] = Json(c.scenarioId);
    j["executableId"] = Json(c.executableId);
    j["name"] = Json(c.name);

    auto params = Json.emptyArray;
    foreach (ref p; c.parameters) {
      auto pj = Json.emptyObject;
      pj["key"] = Json(p.key);
      pj["value"] = Json(p.value);
      params ~= pj;
    }
    j["parameters"] = params;

    auto artifacts = Json.emptyArray;
    foreach (ref a; c.inputArtifacts) {
      auto aj = Json.emptyObject;
      aj["key"] = Json(a.key);
      aj["artifactId"] = Json(a.artifactId);
      artifacts ~= aj;
    }
    j["inputArtifacts"] = artifacts;

    j["createdAt"] = Json(c.createdAt);
    return j;
  }
}
