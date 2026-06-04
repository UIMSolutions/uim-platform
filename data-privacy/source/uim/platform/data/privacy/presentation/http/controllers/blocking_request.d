/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.blocking_request;

// import uim.platform.data.privacy.application.usecases.manage.blocking_requests;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.blocking_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BlockingController : ManageHttpController {
  private ManageBlockingRequestsUseCase usecase;

  this(ManageBlockingRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/blocking-requests", &handleCreate);
    router.get("/api/v1/blocking-requests", &handleList);
    router.get("/api/v1/blocking-requests/*", &handleGet);
    router.put("/api/v1/blocking-requests/*", &handleUpdateStatus);
    router.delete_("/api/v1/blocking-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateBlockingRequest r;
    r.tenantId = precheck.tenantId;
    r.dataSubjectId = data.getString("dataSubjectId");
    r.requestedBy = data.getString("requestedBy");
    r.targetSystems = data.getStrings("targetSystems");
    r.reason = data.getString("reason");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Blocking request created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto statusParam = req.headers.get("X-Status-Filter", "");

    BlockingRequest[] items = statusParam.length > 0
      ? usecase.listByStatus(tenantId, statusParam.toBlockingStatus) : usecase.listRequests(
        tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Blocking requests retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BlockingRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid blocking request ID", 400);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Blocking request not found", 404);

    return successResponse("Blocking request retrieved successfully", 200, entry.toJson());
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateBlockingStatusRequest r;
    r.id = BlockingRequestId(precheck.id);
    r.tenantId = precheck.tenantId;
    r.status = data.getString("status");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Blocking request status updated successfully", 200, responseData);
  }

  protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateStatusHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BlockingRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid blocking request ID", 400);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Blocking request deleted successfully", 200, responseData);
  }
}