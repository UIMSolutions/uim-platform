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

  protected override Json listHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto scenarioId = ScenarioId(req.params.get("scenarioId", ""));

    auto configs = scenarioId.isEmpty
      ? usecase.listConfigurations(tenantId, rgId) : usecase.listConfigurations(tenantId, rgId, scenarioId);

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

    return Json.emptyObject
      .set("count", configs.length)
      .set("resources", jarr)
      .set("message", "Configurations retrieved");
  }

  override protected Json createHandler(HTTPServerRequest req) {
    CreateConfigurationRequest r;
    r.tenantId = req.getTenantId;
    auto j = req.json;
    r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.scenarioId = ScenarioId(req.params.get("scenarioId", ""));
    r.executableId = ExecutableId(req.params.get("executableId", ""));
    r.name = req.params.get("name", "");

    // TODO: Decide if we want to allow parameter and artifact bindings at configuration level or only at execution level. If we allow at configuration level, we need to add them to the create configuration request and handle them here. 
    //  r.parameterValues = jsonKeyValuePairs(j, "parameterBindings");
    // r.inputArtifacts = jsonKeyValuePairs(j, "inputArtifactBindings");
  
    auto result = usecase.createConfiguration(r);
    if (result.hasError)
            return errorResponse(result.message, 400);
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Configuration created");

      return resp;
    } else {
      auto resp = Json.emptyObject
        .set("error", result.message);
      return resp;
    }
  }

  protected override Json getHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto c = usecase.getConfiguration(tenantId, rgId, id);
    if (c.isNull) {
      return Json.emptyObject
        .set("error", "Configuration not found")
        .set("message", "No configuration found with the given ID")
        .set("statusCode", 404);
    }

    return Json.emptyObject
      .set("id", c.id)
      .set("scenarioId", c.scenarioId)
      .set("executableId", c.executableId)
      .set("name", c.name)
      .set("createdAt", c.createdAt)
      .set("statusCode", 200);
  }

  protected override Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = req.getTenantId;
    auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteConfiguration(tenantId, rgId, id);
    if (result.hasError) {
      return Json.emptyObject
        .set("error", result.message)
        .set("message", "Failed to delete configuration")
        .set("statusCode", 404);
    }

    return Json.emptyObject
      .set("message", "Configuration deleted")
      .set("statusCode", 200);
  }
}
