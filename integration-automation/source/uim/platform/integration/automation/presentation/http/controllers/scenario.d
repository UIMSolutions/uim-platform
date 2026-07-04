/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.scenario;

// import uim.platform.integration.automation.application.usecases.manage.scenarios;
// import uim.platform.integration.automation.application.dto;

// import uim.platform.integration.automation.domain.entities.integration_scenario;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ScenarioController : ManageHttpController {
  private ManageScenariosUseCase useCase;

  this(ManageScenariosUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/scenarios", &handleCreate);
    router.get("/api/v1/scenarios", &handleList);
    router.get("/api/v1/scenarios/*", &handleGet);
    router.put("/api/v1/scenarios/*", &handleUpdate);
    router.delete_("/api/v1/scenarios/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateScenarioRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = parseScenarioCategory(data.getString("category"));
    r.version_ = data.getString("version");
    r.sourceSystemType = toSystemType(data.getString("sourceSystemType"));
    r.targetSystemType = toSystemType(data.getString("targetSystemType"));
    r.prerequisites = data.getStrings("prerequisites");
    r.stepTemplates = parseStepTemplates(j);
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createScenario(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = useCase.listScenarios(tenantId);
    auto arr = items.map!(s => s.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Scenario list retrieved successfully", 200, resp);

  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ScenarioId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid Scenario ID", 400);

    auto scenario = useCase.getScenario(tenantId, id);
    if (scenario.isNull)
      return errorResponse("Scenario not found", 404);

    auto responseData = scenario.toJson();
    return successResponse("Scenario retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ScenarioId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid Scenario ID", 400);

    auto data = precheck.data;
    auto r = UpdateScenarioRequest();
    r.scenarioid = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = parseScenarioCategory(data.getString("category"));
    r.version_ = data.getString("version");
    r.status = parseScenarioStatus(data.getString("status"));
    r.sourceSystemType = toSystemType(data.getString("sourceSystemType"));
    r.targetSystemType = toSystemType(data.getString("targetSystemType"));
    r.prerequisites = data.getStrings("prerequisites");
    r.stepTemplates = parseStepTemplates(j);

    auto result = useCase.updateScenario(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    auto result = useCase.deleteScenario(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scenario deleted successfully", 200, responseData);
  }

  private static ScenarioStepTemplate[] parseStepTemplates(Json j) {
    ScenarioStepTemplate[] result;
    auto v = "stepTemplates" in j;
    if (v.isNull || (v).type != Json.Type.array.toJson)
      return result;
    foreach (item; *v) {
      if (item.isObject) {
        ScenarioStepTemplate t;
        t.name = item.getString("name");
        t.description = item.getString("description");
        t.type_ = parseStepType(item.getString("type"));
        t.priority = parseStepPriority(item.getString("priority"));
        t.sequenceNumber = jsonInt(item, "sequenceNumber");
        t.assignedRole = item.getString("assignedRole");
        t.instructions = item.getString("instructions");
        t.automationEndpoint = item.getString("automationEndpoint");
        t.automationPayload = item.getString("automationPayload");
        t.requiresSourceSystem = item.getBoolean("requiresSourceSystem");
        t.requiresTargetSystem = item.getBoolean("requiresTargetSystem");
        t.estimatedDurationMinutes = jsonInt(item, "estimatedDurationMinutes");
        result ~= t;
      }
    }
    return result;
  }
}
