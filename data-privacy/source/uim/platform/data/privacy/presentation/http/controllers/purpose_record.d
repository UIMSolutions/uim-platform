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
class PurposeRecordController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreatePurposeRecordRequest r;
      r.tenantId = tenantId;
      r.subjectId = DataSubjectId(data.getString("dataSubjectId"));
      r.contextId = BusinessContextId(data.getString("businessContextId"));
      r.purpose = data.getString("purpose");
      r.legalBasis = data.getString("legalBasis");
      r.residenceDays = data.getInteger("residenceDays");
      r.retentionDays = data.getInteger("retentionDays");
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

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

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

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto recordId = PurposeRecordId(precheck.id);

      auto record = usecase.getRecord(tenantId, recordId);
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
      auto tenantId = precheck.tenantId;
      DeactivatePurposeRecordRequest r;
      r.tenantId = tenantId;
      r.recordId = PurposeRecordId(precheck.id);

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

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto recordId = PurposeRecordId(precheck.id);

      usecase.deleteRecord(tenantId, recordId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
