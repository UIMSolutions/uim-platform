/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.purpose_record;
// 
// import uim.platform.data.privacy.application.usecases.manage.purpose_records;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.purpose_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class PurposeRecordController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

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
    r.validFrom = data.getLong("validFrom");
    r.validUntil = data.getLong("validUntil");

    auto result = usecase.createRecord(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Purpose record created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listRecords(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Purpose records retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto recordId = PurposeRecordId(precheck.id);

    auto record = usecase.getRecord(tenantId, recordId);
    if (record.isNull)
      return errorResponse("Purpose record not found", 404);

    auto responseData = record.toJson();
    return successResponse("Purpose record retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json deactivateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    DeactivatePurposeRecordRequest r;
    r.tenantId = tenantId;
    r.recordId = PurposeRecordId(precheck.id);

    auto result = usecase.deactivateRecord(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Purpose record deactivated successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleDeactivate", "deactivateHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto recordId = PurposeRecordId(precheck.id);

    auto result = usecase.deleteRecord(tenantId, recordId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Purpose record deleted successfully", "Deleted", 200, responseData);
  }
}
