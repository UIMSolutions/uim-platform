/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers.data_record;




// 
// 
// import uim.platform.data.attribute_recommendation.application.usecases.manage.data_records;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.data_record;
// import uim.platform.data.attribute_recommendation.domain.types;

import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:

class DataRecordController : PlatformController {
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

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      auto r = CreateDataRecordRequest();
      r.tenantId = tenantId;
      r.datasetId = j.getString("datasetId");
      r.attributes = j.getString("attributes");
      r.labels = j.getString("labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDataRecord(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data record created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);

      auto record = usecase.getDataRecord(tenantId, id);
      if (record.isNull) {
        writeError(res, 404, "Record not found");
        return;
      }
      res.writeJsonBody(record.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetListByDataset(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto datasetId = DatasetId(extractIdFromPath(req.requestURI));
      
      auto items = usecase.listDataRecords(tenantId, datasetId);
      auto arr = items.map!(r => r.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Data records retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DataRecordId(extractIdFromPath(req.requestURI));

      auto result = usecase.validateDataRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("validated"))
            .set("message", "Data record validated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetReject(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DataRecordId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto result = usecase.rejectDataRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("rejected"))
            .set("message", "Data record rejected successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DataRecordId(extractIdFromPath(req.requestURI));

      auto result = usecase.deleteDataRecord(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("deleted", true)
            .set("message", "Data record deleted successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  
}
