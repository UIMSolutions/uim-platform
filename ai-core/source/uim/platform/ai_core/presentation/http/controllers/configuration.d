/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.configuration;

import uim.platform.ai_core.application.usecases.manage.configurations;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class ConfigurationController : SAPController {
  private ManageConfigurationsUseCase uc;

  this(ManageConfigurationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v2/lm/configurations", &handleList);
    router.get("/api/v2/lm/configurations/*", &handleGet);
    router.post("/api/v2/lm/configurations", &handleCreate);
    router.delete_("/api/v2/lm/configurations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConfigurationRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.scenarioId = jsonStr(j, "scenarioId");
      r.executableId = jsonStr(j, "executableId");
      r.name = jsonStr(j, "name");
      r.parameterValues = jsonKeyValuePairs(j, "parameterBindings");
      r.inputArtifacts = jsonKeyValuePairs(j, "inputArtifactBindings");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Configuration created");
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

      typeof(uc.list(rgId)) configs;
      if (scenarioId.length > 0)
        configs = uc.listByScenario(scenarioId, rgId);
      else
        configs = uc.list(rgId);

      auto jarr = Json.emptyArray;
      foreach (ref c; configs) {
        auto cj = Json.emptyObject;
        cj["id"] = Json(c.id);
        cj["scenarioId"] = Json(c.scenarioId);
        cj["executableId"] = Json(c.executableId);
        cj["name"] = Json(c.name);
        cj["createdAt"] = Json(c.createdAt);

        // Parameter bindings
        auto pbArr = Json.emptyArray;
        foreach (ref pv; c.parameterValues) {
          auto pvj = Json.emptyObject;
          pvj["key"] = Json(pv.key);
          pvj["value"] = Json(pv.value);
          pbArr ~= pvj;
        }
        cj["parameterBindings"] = pbArr;

        // Input artifact bindings
        auto iaArr = Json.emptyArray;
        foreach (ref ia; c.inputArtifacts) {
          auto iaj = Json.emptyObject;
          iaj["key"] = Json(ia.key);
          iaj["artifactId"] = Json(ia.artifactId);
          iaArr ~= iaj;
        }
        cj["inputArtifactBindings"] = iaArr;

        jarr ~= cj;
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
      auto rgId = req.headers.get("AI-Resource-Group", "");

      auto c = uc.get_(id, rgId);
      if (c.id.length == 0) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject;
      resp["id"] = Json(c.id);
      resp["scenarioId"] = Json(c.scenarioId);
      resp["executableId"] = Json(c.executableId);
      resp["name"] = Json(c.name);
      resp["createdAt"] = Json(c.createdAt);
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
