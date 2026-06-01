/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.model;

// import uim.platform.ai_launchpad.application.usecases.manage.models;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ModelController : ManageController {
  private ManageModelsUseCase usecase;

  this(ManageModelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/models", &handleRegister);
    router.get("/api/v1/models", &handleList);
    router.get("/api/v1/models/*", &handleGet);
    router.patch("/api/v1/models/*", &handlePatch);
    router.delete_("/api/v1/models/*", &handleDelete);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    RegisterModelRequest r;
    r.connectionId = connectionId;
    r.name = data.getString("name");
    r.version_ = data.getString("version");
    r.description = data.getString("description");
    r.scenarioId = data.getString("scenarioId");
    r.executionId = data.getString("executionId");
    r.url = data.getString("url");
    r.size = data.getLong("size");
    r.labels = data.getStrings("labels");

    auto result = usecase.registerModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Model registered successfully", "Created", 201, resp);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = registerHandler(req);
      res.writeJsonBody(resp, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

    auto models = scenarioId.isEmpty
      ? usecase.listModels(tenantId, connectionId) : usecase.listModels(tenantId, connectionId, scenarioId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Model list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto model = usecase.getModel(tenantId, connectionId, id);
    if (model.isNull)
      return errorResponse("Model not found", 404);

    auto responseData = model.toJson();
    return successResponse("Model retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelId(precheck.id);
    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    PatchModelRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.modelId = id;
    r.description = data.getString("description");
    r.status = data.getString("status");

    auto result = usecase.patchModel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Model updated successfully", "Updated", 200, resp);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response.data, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ModelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid model ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto result = usecase.deleteModel(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Model deleted successfully", "Deleted", 200, responseData);
  }
}
