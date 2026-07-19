/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.destruction_request;
// import uim.platform.data.privacy.application.usecases.manage.destruction_requests;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.destruction_request;
import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class DestructionRequestController : ManageHttpController {
  private ManageDestructionRequestsUseCase usecase;

  this(ManageDestructionRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destruction-requests", &handleCreate);
    router.get("/api/v1/destruction-requests", &handleList);
    router.get("/api/v1/destruction-requests/*", &handleGet);
    router.put("/api/v1/destruction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/destruction-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDestructionRequest r;
    r.tenantId = tenantId;
    r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.requestedBy = UserId(data.getString("requestedBy"));
    r.targetSystems = data.getStrings("targetSystems");
    r.archiveRequestId = data.getString("archiveRequestId");
    r.blockingRequestId = data.getString("blockingRequestId");
    r.reason = data.getString("reason");
    r.scheduledAt = data.getLong("scheduledAt");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destruction request created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listRequests(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Destruction requests retrieved successfully", "OK", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestructionRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid request ID", 400);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Destruction request not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Destruction request retrieved successfully", "OK", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestructionRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid request ID", 400);

    auto data = precheck.data;
    UpdateDestructionStatusRequest r;
    r.requestId = id;
    r.tenantId = tenantId;
    r.status = data.getString("status");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Destruction request status updated successfully", "Updated", 200, resp);
  }

  mixin(HandleTemplate!("handleUpdateStatus", "updateStatusHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestructionRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid request ID", 400);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Destruction request deleted successfully", "Deleted", 200, responseData);
  }
}
