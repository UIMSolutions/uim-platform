/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.deletion;

// import uim.platform.data.privacy.application.usecases.manage.deletion_requests;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.deletion_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DeletionController : ManageController {
  private ManageDeletionRequestsUseCase usecase;

  this(ManageDeletionRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deletion-requests", &handleCreate);
    router.get("/api/v1/deletion-requests", &handleList);
    router.get("/api/v1/deletion-requests/*", &handleGet);
    router.put("/api/v1/deletion-requests/*", &handleUpdateStatus);
    router.delete_("/api/v1/deletion-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDeletionRequest r;
    r.tenantId = tenantId;
    r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.requestedBy = UserId(data.getString("requestedBy"));
    r.targetSystems = data.getStrings("targetSystems");
    r.reason = data.getString("reason");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deletion request created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto statusParam = req.headers.get("X-Status-Filter", "");
    auto subjectParam = req.headers.get("X-Subject-Filter", "");

    DeletionRequest[] items;
    if (statusParam.length > 0)
      items = usecase.listByStatus(tenantId, statusParam.toDeletionStatus());
    else if (subjectParam.length > 0)
      items = usecase.listByDataSubject(tenantId, DataSubjectId(subjectParam));
    else
      items = usecase.listRequests(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Deletion request list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeletionRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deletion request ID", 400);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Deletion request not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Deletion request retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateDeletionStatusRequest r;
    r.requestId = DeletionRequestId(precheck.id);
    r.tenantId = tenantId;
    r.status = data.getString("status");
    r.blockerReason = data.getString("blockerReason");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Deletion request status updated successfully", "Updated", 200, resp);
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
    auto id = DeletionRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deletion request ID", 400);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deletion request deleted successfully", "Deleted", 200, responseData);
  }
}
