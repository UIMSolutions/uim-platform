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
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class PurposeRecordController : PlatformController {
  private ManagePurposeRecordsUseCase usecase;

  this(ManagePurposeRecordsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/purpose-records", &handleCreate);
    router.get("/api/v1/purpose-records", &handleList);
    router.get("/api/v1/purpose-records/*", &handleGet);
    router.post("/api/v1/purpose-records/*/deactivate", &handleDeactivate);
    router.delete_("/api/v1/purpose-records/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      
      CreatePurposeRecordRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.businessContextId = BusinessContextId(j.getString("businessContextId"));
      r.purpose = j.getString("purpose").to!ProcessingPurpose;
      r.legalBasis = j.getString("legalBasis").to!LegalBasis;
      r.residenceDays = j.getInteger("residenceDays");
      r.retentionDays = j.getInteger("retentionDays");
      r.validFrom = j.getLong("validFrom");
      r.validUntil = j.getLong("validUntil");

      auto result = usecase.createRecord(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Purpose record created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto items = usecase.listRecords(tenantId);
      auto arr = items.map!(record => record.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Purpose records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = extractIdFromPath(req.requestURI);

      auto record = usecase.getRecord(tenantId, id);
      if (record.isNull) {
        writeError(res, 404, "Purpose record not found");
        return;
      }
      res.writeJsonBody(record.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      DeactivatePurposeRecordRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;

      auto result = usecase.deactivateRecord(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = PurposeRecordId(extractIdFromPath(req.requestURI));

      usecase.deleteRecord(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const PurposeRecord e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("businessContextId", e.businessContextId)
      .set("purpose", e.purpose.to!string)
      .set("status", e.status.to!string)
      .set("legalBasis", e.legalBasis)
      .set("residenceDays", e.residenceDays)
      .set("retentionDays", e.retentionDays)
      .set("validFrom", e.validFrom)
      .set("validUntil", e.validUntil)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("deactivatedAt", e.deactivatedAt);
  }
}
