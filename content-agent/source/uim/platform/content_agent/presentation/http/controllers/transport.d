/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.transport;

// import uim.platform.content_agent.application.usecases.manage.transport_requests;

// import uim.platform.content_agent.domain.entities.transport_request;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
class TransportController : ManageHttpController {
  private ManageTransportRequestsUseCase usecase;

  this(ManageTransportRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/transports", &handleCreate);
    router.get("/api/v1/transports", &handleList);
    router.get("/api/v1/transports/*", &handleGet);
    router.post("/api/v1/transports/release", &handleRelease);
    router.post("/api/v1/transports/cancel", &handleCancel);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateTransportRequest();
    r.tenantId = tenantId;
    r.sourceSubaccount = data.getString("sourceSubaccount");
    r.targetSubaccount = data.getString("targetSubaccount");
    r.description = data.getString("description");
    r.mode = data.getString("mode");
    r.packageIds = data.getStrings("packageIds");
    r.queueId = data.getString("queueId");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createTransportRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Transport request created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto transports = usecase.listTransportRequests(tenantId);
    auto list = transports.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Transport request list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TransportRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid transport request ID", 400);

    auto treq = usecase.getTransportRequest(tenantId, id);
    if (treq.isNull)
      return errorResponse("Transport request not found", 404);

    auto responseData = treq.toJson();
    return successResponse("Transport request retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json releaseHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = ReleaseTransportRequest();
    r.requestId = data.getString("requestId");
    r.tenantId = tenantId;
    r.releasedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.releaseTransport(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("status", "released");

    return successResponse("Transport request released successfully", "Released", 200, responseData);
  }

  protected void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = releaseHandler(req);
      res.writeJsonBody(resp, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json cancelHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto requestId = data.getString("requestId");

    auto result = usecase.cancelTransport(tenantId, requestId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id)
      .set("status", "cancelled");
    return successResponse("Transport request cancelled successfully", "Cancelled", 200, responseData);
  }

  protected void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = cancelHandler(req);

      res.writeJsonBody(response.data, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
