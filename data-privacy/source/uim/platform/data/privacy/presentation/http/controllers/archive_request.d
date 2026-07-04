/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.archive_request;
// import uim.platform.data.privacy.application.usecases.manage.archive_requests;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.archive_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ArchiveRequestController : ManageHttpController {
  private ManageArchiveRequestsUseCase usecase;

  this(ManageArchiveRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/archive-requests", &handleCreate);
    router.get("/api/v1/archive-requests", &handleList);
    router.get("/api/v1/archive-requests/*", &handleGet);
    router.put("/api/v1/archive-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/archive-requests/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateArchiveRequest r;
    r.tenantId = tenantId;
    r.subjectId = data.getString("dataSubjectId");
    r.requestedBy = data.getString("requestedBy");
    r.targetSystems = data.getStrings("targetSystems");
    r.categories = data.getStrings("categories");
    r.archiveLocation = data.getString("archiveLocation");
    r.reason = data.getString("reason");
    r.isTestMode = data.getBoolean("isTestMode", false);
    r.scheduledAt = data.getLong("scheduledAt");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Archive request created successfully", 201, responseData);
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
    return successResponse("Archive requests retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ArchiveRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid archive request ID", 400);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Archive request retrieved successfully", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ArchiveRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid archive request ID", 400);

    auto data = precheck.data;
    UpdateArchiveStatusRequest r;
    r.tenantId = tenantId;
    r.requestId = id;
    r.status = data.getString("status");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Archive request status updated successfully", 200, responseData);
  }

  mixin(HandleTemplate!("handleUpdateStatus", "updateStatusHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ArchiveRequestId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid archive request ID", 400);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Archive request deleted successfully", 200, responseData);
  }
}
