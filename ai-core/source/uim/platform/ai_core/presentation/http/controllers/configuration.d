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

// mixin(ShowModule!());

@safe:
class ConfigurationController : ManageHttpController {
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
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto scenarioId = ScenarioId(req.params.get("scenarioId", ""));

    auto configs = scenarioId.isEmpty
      ? usecase.listConfigurations(tenantId, rgId) : usecase.listConfigurations(tenantId, rgId, scenarioId);

    auto list = Json.emptyArray;
    foreach (c; configs) {
      // Parameter bindings
      auto pbArr = c.parameterValues.map!(pv => Json.emptyObject.set("key", pv.key).set("value", pv
          .value)).array.toJson;
      auto iaArr = c.inputArtifacts.map!(ia => Json.emptyObject.set("key", ia.key).set("artifactId", ia
          .artifactId)).array.toJson;

      list ~= Json.emptyObject
        .set("id", c.id)
        .set("scenarioId", c.scenarioId)
        .set("executableId", c.executableId)
        .set("name", c.name)
        .set("createdAt", c.createdAt)
        .set("parameterBindings", pbArr)
        .set("inputArtifactBindings", iaArr);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Configurations retrieved successfully", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    CreateConfigurationRequest r;
    r.tenantId = tenantId;
    auto data = precheck.data;
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

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Configuration created successfully", "Created", 201, responseData);
  }

  protected override Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto c = usecase.getConfiguration(tenantId, rgId, id);
    if (c.isNull)
      return errorResponse("Configuration not found", 404);

    auto responseData = Json.emptyObject
      .set("id", c.id)
      .set("scenarioId", c.scenarioId)
      .set("executableId", c.executableId)
      .set("name", c.name)
      .set("createdAt", c.createdAt);
    return successResponse("Configuration retrieved successfully", "OK", 200, responseData);
  }

  protected override Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteConfiguration(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = Json.emptyObject;
    return successResponse("Configuration deleted successfully", "OK", 200, responseData);
  }
}
