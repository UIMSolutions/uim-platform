/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.correction_request;
// import uim.platform.data.privacy.application.usecases.manage.correction_requests;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.correction_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class CorrectionRequestController : ManageHttpController {
  private ManageCorrectionRequestsUseCase usecase;

  this(ManageCorrectionRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/correction-requests", &handleCreate);
    router.get("/api/v1/correction-requests", &handleList);
    router.get("/api/v1/correction-requests/*", &handleGet);
    router.put("/api/v1/correction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/correction-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateCorrectionRequest r;
    r.tenantId = tenantId;
    r.subjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.requestedBy = UserId(data.getString("requestedBy"));
    r.targetSystems = data.getStrings("targetSystems");
    r.fieldName = data.getString("fieldName");
    r.currentValue = data.getString("currentValue");
    r.correctedValue = data.getString("correctedValue");
    r.reason = data.getString("reason");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Correction request created successfully", "Created", 201, responseData);
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
    return successResponse("Correction request list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CorrectionRequestId(precheck.id);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Correction request not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Correction request retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CorrectionRequestId(precheck.id);

    auto data = precheck.data;
    UpdateCorrectionStatusRequest r;
    r.tenantId = tenantId;
    r.requestId = id;
    r.status = data.getString("status");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Correction request status updated successfully", "Updated", 200, responseData);
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
    auto id = CorrectionRequestId(precheck.id);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Correction request deleted successfully", "Deleted", 200, responseData);
  }
}