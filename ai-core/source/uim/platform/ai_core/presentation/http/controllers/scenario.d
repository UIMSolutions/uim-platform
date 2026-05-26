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

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto scenarios = usecase.listScenarios(tenantId, rgId);

    auto jsList = Json.emptyArray;
    foreach (s; scenarios) {
      jsList ~= Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("labels", s.labels.map!(label => label.toJson).array.toJson)
        .set("createdAt", s.createdAt)
        .set("updatedAt", s.updatedAt);
    }

    auto responseData = Json.emptyObject
      .set("count", scenarios.length)
      .set("resources", jsList);

    return successResponse("Scenario list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    CreateScenarioRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = rgId;
    r.scenarioId = ScenarioId(data.getString("id"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.labels = getStrings(data, "labels");

    auto result = usecase.createScenario(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScenarioId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scenario ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto s = usecase.getScenario(tenantId, rgId, id);
    if (s.isNull)
      return errorResponse("Scenario not found", 404);

    auto resp = Json.emptyObject
      .set("id", s.id)
      .set("name", s.name)
      .set("description", s.description)
      .set("labels", s.labels.map!(label => label.toJson).array.toJson)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt);
    return successResponse("Scenario retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScenarioId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scenario ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteScenario(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario deleted successfully", "Deleted", 200, responseData);
  }
}
