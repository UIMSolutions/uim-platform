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

class DataRecordController : ManageController {
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
      r.tenantId = tenantId;
      r.datasetId = data.getString("datasetId");
      r.attributes = data.getString("attributes");
      r.labels = data.getString("labels");
      r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

      auto result = usecase.createDataRecord(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Data record created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;

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

  override protected void handleListByDataset(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto datasetId = DatasetId(precheck.id);
      
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

  protected void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = DataRecordId(precheck.id);

      auto result = usecase.validateDataRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("validated"))
            .set("message", "Data record validated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleReject(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DataRecordId(precheck.id);
      
      auto result = usecase.rejectDataRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("status", Json("rejected"))
            .set("message", "Data record rejected successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = DataRecordId(precheck.id);

      auto result = usecase.deleteDataRecord(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("deleted", true)
            .set("message", "Data record deleted successfully");

        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.message);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  
}
