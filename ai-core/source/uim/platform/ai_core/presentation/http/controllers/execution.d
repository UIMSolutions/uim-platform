/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.execution;
// import uim.platform.ai_core.application.usecases.manage.executions;


import uim.platform.ai_core;

// mixin(ShowModule!());

@safe:

class ExecutionController : ManageHttpController {
  private ManageExecutionsUseCase usecase;

  this(ManageExecutionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/executions", &handleCreate);
    router.get("/api/v2/lm/executions", &handleList);
    router.get("/api/v2/lm/executions/*", &handleGet);
    router.patch("/api/v2/lm/executions/*", &handlePatch);
    router.delete_("/api/v2/lm/executions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateExecutionRequest r;
    r.tenantId = tenantId;
    r.groupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.configurationId = ConfigurationId(data.getString("configurationId"));

    auto result = usecase.createExecution(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Execution created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto items = usecase.listExecutions(tenantId, rgId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
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
      return errorResponse("Invalid execution ID");

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto ex = usecase.getExecution(tenantId, rgId, id);
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
      return errorResponse("Invalid execution ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto data = precheck.data;
    PatchExecutionRequest r;
    r.tenantId = tenantId;
    r.groupId = rgId;
    r.executionId = id;
    r.targetStatus = data.getString("targetStatus");

    auto result = usecase.patchExecution(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Execution modified successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ExecutionId(precheck.id);
    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usecase.deleteExecution(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Execution deleted successfully", 200, responseData);
  }
}
