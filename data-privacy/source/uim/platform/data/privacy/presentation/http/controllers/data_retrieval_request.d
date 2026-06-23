/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_retrieval_request;

// import uim.platform.data.privacy.application.usecases.manage.data_retrievals;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.data_retrieval_request;
import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class DataRetrievalController : ManageHttpController {
  private ManageDataRetrievalsUseCase usecase;

  this(ManageDataRetrievalsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-retrievals", &handleCreate);
    router.get("/api/v1/data-retrievals", &handleList);
    router.get("/api/v1/data-retrievals/*", &handleGet);
    router.put("/api/v1/data-retrievals/*", &handleUpdateStatus);
    router.delete_("/api/v1/data-retrievals/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataRetrievalRequest r;
    r.tenantId = tenantId;
    r.dataSubjectId = DataSubjectId(data.getString("dataSubjectId"));
    r.requestedBy = data.getString("requestedBy");
    r.targetSystems = data.getStrings("targetSystems");
    r.reason = data.getString("reason");

    auto result = usecase.createRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data retrieval request created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto statusParam = req.headers.get("X-Status-Filter", "");
    auto subjectParam = req.headers.get("X-Subject-Filter", "");

    DataRetrievalRequest[] items = statusParam.length > 0
      ? usecase.listByStatus(tenantId, toRetrievalStatus(statusParam)) 
      : usecase.listRequests(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Data retrieval request list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataRetrievalRequestId(precheck.id);

    auto entry = usecase.getRequest(tenantId, id);
    if (entry.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Data retrieval request retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateRetrievalStatusRequest r;
    r.id = DataRetrievalRequestId(precheck.id);
    r.tenantId = tenantId;
    r.status = data.getString("status");
    r.downloadUrl = data.getString("downloadUrl");
    r.totalFields = data.getLong("totalFields");

    auto result = usecase.updateStatus(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data retrieval request status updated successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleUpdateStatus", "updateStatusHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataRetrievalRequestId(precheck.id);

    auto result = usecase.deleteRequest(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data retrieval request deleted successfully", "Deleted", 200, responseData);
  }
}
