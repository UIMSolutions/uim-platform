/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers.data_record;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.manage.data_records;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.data_record;
// import uim.platform.data.attribute_recommendation.domain.types;

import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:

class DataRecordController : PlatformController {
  private ManageDataRecordsUseCase uc;

  this(ManageDataRecordsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-records", &handleCreate);
    router.get("/api/v1/data-records/*", &handleGetById);
    router.get("/api/v1/datasets/records/*", &handleListByDataset);
    router.post("/api/v1/data-records/validate/*", &handleValidate);
    router.post("/api/v1/data-records/reject/*", &handleReject);
    router.delete_("/api/v1/data-records/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDataRecordRequest();
      r.tenantId = req.getTenantId;
      r.datasetId = j.getString("datasetId");
      r.attributes = j.getString("attributes");
      r.labels = j.getString("labels");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createRecord(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
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

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto record = uc.getRecord(tenantId, id);
      if (record is null) {
        writeError(res, 404, "Record not found");
        return;
      }
      res.writeJsonBody(serializeRecord(*record), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByDataset(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto datasetId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto items = uc.listByDataset(datasettenantId, id);

      auto arr = items.map!(r => serializeRecord(r)).array;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Data records retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.validateRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
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

  private void handleReject(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.rejectRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deleteRecord(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("deleted", Json(true))
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

  private static Json serializeRecord(const DataRecord r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("datasetId", r.datasetId)
      .set("tenantId", r.tenantId)
      .set("attributes", r.attributes)
      .set("labels", r.labels)
      .set("status", r.status.to!string)
      .set("createdBy", r.createdBy)
      .set("createdAt", r.createdAt);
  }
}
