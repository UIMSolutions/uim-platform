/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.purpose_record;
// 
// import uim.platform.data.privacy.application.usecases.manage.purpose_records;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.purpose_record;
// import uim.platform.data.privacy.presentation.http.json_utils;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class PurposeRecordController : PlatformController {
  private ManagePurposeRecordsUseCase uc;

  this(ManagePurposeRecordsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/purpose-records", &handleCreate);
    router.get("/api/v1/purpose-records", &handleList);
    router.get("/api/v1/purpose-records/*", &handleGetById);
    router.post("/api/v1/purpose-records/*/deactivate", &handleDeactivate);
    router.delete_("/api/v1/purpose-records/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreatePurposeRecordRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.businessContextId = j.getString("businessContextId");
      r.purpose = j.getString("purpose");
      r.legalBasis = j.getString("legalBasis");
      r.residenceDays = cast(int) jsonLong(j, "residenceDays");
      r.retentionDays = cast(int) jsonLong(j, "retentionDays");
      r.validFrom = jsonLong(j, "validFrom");
      r.validUntil = jsonLong(j, "validUntil");

      auto result = uc.createRecord(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listRecords(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getRecord(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Purpose record not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      DeactivatePurposeRecordRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;

      auto result = uc.deactivateRecord(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteRecord(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const PurposeRecord e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["dataSubjectId"] = Json(e.dataSubjectId);
    j["businessContextId"] = Json(e.businessContextId);
    j["purpose"] = Json(e.purpose);
    j["status"] = Json(e.status.to!string);
    j["legalBasis"] = Json(e.legalBasis);
    j["residenceDays"] = Json(cast(long) e.residenceDays);
    j["retentionDays"] = Json(cast(long) e.retentionDays);
    j["validFrom"] = Json(e.validFrom);
    j["validUntil"] = Json(e.validUntil);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    j["deactivatedAt"] = Json(e.deactivatedAt);
    return j;
  }
}
