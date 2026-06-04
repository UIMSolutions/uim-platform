/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers.data_record;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.data_records;
// import uim.platform.data_attribute_recommendation.application.dto;
// import uim.platform.data_attribute_recommendation.domain.entities.data_record;
// import uim.platform.data_attribute_recommendation.domain.types;

import uim.platform.data_attribute_recommendation;

mixin(ShowModule!());
@safe:

class DataRecordController : ManageHttpController {
  private ManageDataRecordsUseCase usecase;

  this(ManageDataRecordsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-records", &handleCreate);
    router.get("/api/v1/data-records/*", &handleGet);
    router.get("/api/v1/datasets/records/*", &handleListByDataset);
    router.post("/api/v1/data-records/validate/*", &handleValidate);
    router.post("/api/v1/data-records/reject/*", &handleReject);
    router.delete_("/api/v1/data-records/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateDataRecordRequest();
    r.tenantId = precheck.tenantId;
    r.datasetId = data.getString("datasetId");
    r.attributes = data.getString("attributes");
    r.labels = data.getString("labels");
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

    auto result = usecase.createDataRecord(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data record created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataRecordId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data record ID", 400);

    auto record = usecase.getDataRecord(tenantId, id);
    if (record.isNull)
      return errorResponse("Data record not found", 404);

    auto responseData = record.toJson();
    return successResponse("Data record retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json listByDatasetHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto datasetId = DatasetId(precheck.id);

    auto items = usecase.listDataRecords(tenantId, datasetId);
    auto list = items.map!(r => r.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", list)
      .set("totalCount", items.length);

    return successResponse("Data records retrieved successfully", "Retrieved", 200, responseData);
  }

  protected void handleListByDataset(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listByDatasetHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json validateHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;

    auto result = usecase.validateDataRecord(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", Json("validated"))
      .set("message", "Data record validated successfully");

    return successResponse("Data record validated successfully", "Validated", 200, resp);
  }

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = validateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json rejectHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataRecordId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data record ID", 400);

    auto result = usecase.rejectDataRecord(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("status", Json("rejected"));

    return successResponse("Data record rejected successfully", "Rejected", 200, resp);
  }

  protected void handleReject(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = rejectHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataRecordId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data record ID", 400);

    auto result = usecase.deleteDataRecord(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data record deleted successfully", "Deleted", 200, responseData);
  }
}
