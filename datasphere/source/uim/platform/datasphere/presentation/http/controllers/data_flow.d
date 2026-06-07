/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.data_flow;
// import uim.platform.datasphere.application.usecases.manage.data_flows;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!());

@safe:

class DataFlowController : ManageHttpController {
  private ManageDataFlowsUseCase usecase;

  this(ManageDataFlowsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/dataFlows", &handleList);
    router.get("/api/v1/datasphere/dataFlows/*", &handleGet);
    router.post("/api/v1/datasphere/dataFlows", &handleCreate);
    router.delete_("/api/v1/datasphere/dataFlows/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateDataFlowRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.scheduleExpression = data.getString("scheduleExpression");
    r.scheduleFrequency = data.getString("scheduleFrequency");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data flow created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto flows = usecase.list(spaceId);

    auto list = Json.emptyArray;
    foreach (df; flows) {
      list ~= Json.emptyObject
        .set("id", df.id)
        .set("name", df.name)
        .set("description", df.description)
        .set("lastRunAt", df.lastRunAt)
        .set("lastRunDurationMs", df.lastRunDurationMs)
        .set("createdAt", df.createdAt);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Data flows retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto id = DataFlowId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto df = usecase.getDataFlow(tenantId, spaceId, id);
    if (df.isNull)
      return errorResponse("Data flow not found", 404);

    auto responseData = Json.emptyObject
      .set("id", df.id)
      .set("name", df.name)
      .set("description", df.description)
      .set("scheduleExpression", df.scheduleExpression)
      .set("lastRunAt", df.lastRunAt)
      .set("lastRunDurationMs", df.lastRunDurationMs)
      .set("lastRunMessage", df.lastRunMessage)
      .set("createdAt", df.createdAt)
      .set("updatedAt", df.updatedAt);
    return successResponse("Data flow retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto id = DataFlowId(precheck.id);
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto result = usecase.deleteDataFlow(
      tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(
        result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data flow deleted successfully", "Deleted", 200, responseData);
  }
}
