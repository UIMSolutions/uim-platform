/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.scenario;

// import uim.platform.ai_launchpad.application.usecases.manage.scenarios;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

class ScenarioController : ManageHttpController {
  private ManageScenariosUseCase usecase;

  this(ManageScenariosUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/scenarios/sync", &handleSync);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGet);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  protected Json syncHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    SyncScenarioRequest request;
    request.tenantId = tenantId;
    request.scenarioId = ScenarioId(data.getString("scenarioId"));
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.labels = data.getStrings("labels");

    auto result = usecase.syncScenario(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario synced successfully", "Synced", 201, resp);
  }

  mixin(HandleTemplate!("handleSync", "syncHandler"));

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto scenarios = connectionId.isEmpty
      ? usecase.listScenarios(tenantId) : usecase.listScenarios(tenantId, connectionId);

    auto list = scenarios.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Scenario list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScenarioId(precheck.id);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto s = usecase.getScenario(tenantId, connectionId, id);
    if (s.isNull)
      return errorResponse("Scenario not found", 404);

    auto responseData = s.toJson();
    return successResponse("Scenario retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ScenarioId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid scenario ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto result = usecase.deleteScenario(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario deleted successfully", "Deleted", 200, responseData);
  }
}
