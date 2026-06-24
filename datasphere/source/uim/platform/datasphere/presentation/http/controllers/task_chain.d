/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.task_chain;
// import uim.platform.datasphere.application.usecases.manage.task_chains;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!());

@safe:

class TaskChainController : ManageHttpController {
  private ManageTaskChainsUseCase usecase;

  this(ManageTaskChainsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/taskChains", &handleList);
    router.get("/api/v1/datasphere/taskChains/*", &handleGet);
    router.post("/api/v1/datasphere/taskChains", &handleCreate);
    router.delete_("/api/v1/datasphere/taskChains/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateTaskChainRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.scheduleExpression = data.getString("scheduleExpression");
    r.scheduleFrequency = data.getString("scheduleFrequency");

    auto result = usecase.createTaskChain(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Task chain created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto chains = usecase.listTaskChains(spaceId);
    auto list = Json.emptyArray;
    foreach (tc; chains) {
      list ~= Json.emptyObject
        .set("id", tc.id)
        .set("name", tc.name)
        .set("description", tc.description)
        .set("lastRunAt", tc.lastRunAt)
        .set("lastRunDurationMs", tc.lastRunDurationMs)
        .set("createdAt", tc.createdAt);
    }

    auto response = Json.emptyObject
      .set("count", Json(chains.length))
      .set("resources", list);
    return successResponse("Task chains retrieved successfully", 0, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TaskChainId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid task chain ID", 400);

    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));

    auto tc = usecase.getTaskChain(spaceId, id);
    if (tc.isNull)
      return errorResponse("Task chain not found", 404);

    auto resp = Json.emptyObject
      .set("id", tc.id)
      .set("name", tc.name)
      .set("description", tc.description)
      .set("scheduleExpression", tc.scheduleExpression)
      .set("lastRunAt", tc.lastRunAt)
      .set("lastRunDurationMs", tc.lastRunDurationMs)
      .set("lastRunMessage", tc.lastRunMessage)
      .set("createdAt", tc.createdAt)
      .set("updatedAt", tc.updatedAt);

    return successResponse("Task chain retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto id = TaskChainId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid task chain ID", 400);

    auto result = usecase.deleteTaskChain(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Task chain deleted successfully", 204, Json.emptyObject);
  }
}
