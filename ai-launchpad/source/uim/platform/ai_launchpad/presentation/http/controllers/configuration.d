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

class ConfigurationController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    CreateConfigurationRequest r;
    r.connectionId = connectionId;
    r.scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));
    r.inputArtifacts = jsonPairArray(data, "inputArtifacts");

    auto result = configurations.createConfiguration(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Configuration created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

    auto items = scenarioId.isEmpty
      ? configurations.listConfigurations(tenantId, connectionId) : configurations.listConfigurations(tenantId, connectionId, scenarioId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Configuration list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ConfigurationId(precheck.id);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto c = configurations.getConfiguration(tenantId, connectionId, id);
    if (c.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = job.toJson();
    return successResponse("Configuration retrieved successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto result = configurations.deleteConfiguration(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Configuration deleted successfully", 200, responseData);
  }
}
