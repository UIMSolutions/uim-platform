module uim.platform.data.attribute_recommendation.presentation.http.controllers.data_record;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.manage_data_records;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.data_record;
// import uim.platform.data.attribute_recommendation.domain.types;
// import uim.platform.data.attribute_recommendation.presentation.http.json_utils;

import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:

class DataRecordController : SAPController
{
  private ManageDataRecordsUseCase uc;

  this(ManageDataRecordsUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    super.registerRoutes(router);

    router.post("/api/v1/data-records", &handleCreate);
    router.get("/api/v1/data-records/*", &handleGetById);
    router.get("/api/v1/datasets/records/*", &handleListByDataset);
    router.post("/api/v1/data-records/validate/*", &handleValidate);
    router.post("/api/v1/data-records/reject/*", &handleReject);
    router.delete_("/api/v1/data-records/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateDataRecordRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.datasetId = j.getString("datasetId");
      r.attributes = j.getString("attributes");
      r.labels = j.getString("labels");
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createRecord(r);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto record = uc.getRecord(id, tenantId);
      if (record is null)
      {
        writeError(res, 404, "Record not found");
        return;
      }
      res.writeJsonBody(serializeRecord(*record), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListByDataset(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto datasetId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = uc.listByDataset(datasetId, tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; items)
        arr ~= serializeRecord(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleValidate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.validateRecord(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("validated");
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleReject(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.rejectRecord(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["status"] = Json("rejected");
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = uc.deleteRecord(id, tenantId);
      if (result.isSuccess)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRecord(ref const DataRecord r)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["datasetId"] = Json(r.datasetId);
    j["tenantId"] = Json(r.tenantId);
    j["attributes"] = Json(r.attributes);
    j["labels"] = Json(r.labels);
    j["status"] = Json(r.status.to!string);
    j["createdBy"] = Json(r.createdBy);
    j["createdAt"] = Json(r.createdAt);
    return j;
  }
}
