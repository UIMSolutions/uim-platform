/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.configuration;

// import uim.platform.ai_core.application.usecases.manage.configurations;
// import uim.platform.ai_core.application.dto;

// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class ConfigurationController : ManageController {
  private ManageConfigurationsUseCase usecase;

  this(ManageConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v2/lm/configurations", &handleList);
    router.get("/api/v2/lm/configurations/*", &handleGet);
    router.post("/api/v2/lm/configurations", &handleCreate);
    router.delete_("/api/v2/lm/configurations/*", &handleDelete);
  }

  override Json createHandler(Json data) {
    CreateConfigurationRequest r;
    r.tenantId = data.getTenantId;
    r.resourceGroupId = ResourceGroupId(data.get("AI-Resource-Group", ""));
    r.scenarioId = data.getString("scenarioId");
    r.executableId = data.getString("executableId");
    r.name = data.getString("name");
    r.parameterValues = jsonKeyValuePairs(data, "parameterBindings");
    r.inputArtifacts = jsonKeyValuePairs(data, "inputArtifactBindings");

    auto result = usecase.create(r);
    if (result.success) {
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Configuration created");

      return resp;
    } else {
      auto resp = Json.emptyObject
        .set("error", result.error);
      return resp;
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto scenarioId = req.params.get("scenarioId", "");

      auto configs = scenarioId.isEmpty
        ? usecase.list(tenantId, rgId) : usecase.listByScenario(tenantId, scenarioId, rgId);

      auto jarr = Json.emptyArray;
      foreach (c; configs) {
        // Parameter bindings
        auto pbArr = c.parameterValues.map!(pv => Json.emptyObject.set("key", pv.key).set("value", pv
            .value)).array.toJson;
        auto iaArr = c.inputArtifacts.map!(ia => Json.emptyObject.set("key", ia.key).set("artifactId", ia
            .artifactId)).array.toJson;

        jarr ~= Json.emptyObject
          .set("id", c.id)
          .set("scenarioId", c.scenarioId)
          .set("executableId", c.executableId)
          .set("name", c.name)
          .set("createdAt", c.createdAt)
          .set("parameterBindings", pbArr)
          .set("inputArtifactBindings", iaArr);
      }

      auto resp = Json.emptyObject
        .set("count", configs.length)
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto c = usecase.getConfiguration(tenantId, rgId, id);
      if (c.isNull) {
        writeError(res, 404, "Configuration not found");
        return;
      }

      auto resp = Json.emptyObject
        .set("id", c.id)
        .set("scenarioId", c.scenarioId)
        .set("executableId", c.executableId)
        .set("name", c.name)
        .set("createdAt", c.createdAt);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto result = usecase.deleteConfiguration(tenantId, rgId, id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
