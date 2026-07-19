/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.execution;

// import uim.platform.ai_launchpad.application.usecases.manage.executions;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

class ExecutionController : ManageHttpController {
  private ManageExecutionsUseCase usecase;

  this(ManageExecutionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/executions", &handleCreate);
    router.get("/api/v1/executions", &handleList);
    router.get("/api/v1/executions/*", &handleGet);
    router.patch("/api/v1/executions/bulk", &handleBulkPatch);
    router.patch("/api/v1/executions/*", &handlePatch);
    router.delete_("/api/v1/executions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto data = precheck.data;
    CreateExecutionRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.configurationId = data.getString("configurationId");
    r.resourceGroupId = data.getString("resourceGroupId");

    auto result = usecase.createExecution(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("status", "PENDING");

    return successResponse("Execution scheduled successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

    auto executions = scenarioId.isEmpty
      ? usecase.listExecutions(tenantId, connectionId) : usecase.listExecutions(tenantId, connectionId, scenarioId);

    auto list = executions.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", executions.length)
      .set("resources", list);
    return successResponse("Execution list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ExecutionId(precheck.id);
    if (id.isNull)
      return errorResponse("Execution ID is required", 400);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto ex = usecase.getExecution(tenantId, connectionId, id);
    if (ex.isNull)
      return errorResponse("Execution not found", 404);

    auto responseData = ex.toJson();
    return successResponse("Execution retrieved successfully", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ExecutionId(precheck.id);
    if (id.isNull)
      return errorResponse("Execution ID is required", 400);

    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    PatchExecutionRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.executionId = id;
    r.targetStatus = data.getString("targetStatus");

    auto result = usecase.patchExecution(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Execution updated successfully", 200, resp);
  }

  protected Json bulkPatchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    BulkPatchExecutionRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.executionIds = data.getStrings("executionIds").map!(s => ExecutionId(s)).array;
    r.targetStatus = data.getString("targetStatus");

    auto results = usecase.bulkPatchExecution(r);
    auto jarr = Json.emptyArray;
    foreach (result; results) {
      auto rj = Json.emptyObject
        .set("id", result.id)
        .set("success", result.success);

      if (result.message.length > 0)
        rj["error"] = Json(result.message);
      jarr ~= rj;
    }

    auto resp = Json.emptyObject.set("results", jarr);
    return successResponse("Bulk update completed", 200, resp);
  }

  mixin(HandleTemplate!("handleBulkPatch", "bulkPatchHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ExecutionId(precheck.id);
    if (id.isNull)
      return errorResponse("Execution ID is required", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto result = usecase.deleteExecution(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
      
    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Execution deleted successfully", 200, responseData);
  }
}
