/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.correction_request;
// import uim.platform.data.privacy.application.usecases.manage.correction_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.correction_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class CorrectionRequestController : ManageController {
  private ManageCorrectionRequestsUseCase usecase;

  this(ManageCorrectionRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/correction-requests", &handleCreate);
    router.get("/api/v1/correction-requests", &handleList);
    router.get("/api/v1/correction-requests/*", &handleGet);
    router.put("/api/v1/correction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/correction-requests/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateCorrectionRequest r;
      r.tenantId = tenantId;
      r.subjectId = DataSubjectId(data.getString("dataSubjectId"));
      r.requestedBy = UserId(data.getString("requestedBy"));
      r.targetSystems = getStrings(j, "targetSystems");
      r.fieldName = data.getString("fieldName");
      r.currentValue = data.getString("currentValue");
      r.correctedValue = data.getString("correctedValue");
      r.reason = data.getString("reason");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Correction request created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = usecase.listRequests(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Correction requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = CorrectionRequestId(precheck.id);

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Correction request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;

      UpdateCorrectionStatusRequest r;
      r.tenantId = tenantId;
      r.requestId = CorrectionRequestId(precheck.id);
      r.status = data.getString("status");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Correction request status updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = CorrectionRequestId(precheck.id);

      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const CorrectionRequest e) {
    return Json.emptyObject
    .set("id", e.id)
    .set("tenantId", e.tenantId)
    .set("dataSubjectId", e.dataSubjectId)
    .set("requestedBy", e.requestedBy)
    .set("status", e.status.to!string)
    .set("fieldName", e.fieldName)
    .set("currentValue", e.currentValue)
    .set("correctedValue", e.correctedValue)
    .set("reason", e.reason)
    .set("requestedAt", e.requestedAt)
    .set("completedAt", e.completedAt)
    .set("deadline", e.deadline);
  }

  private static CorrectionStatus parseCorrectionStatus(string status) {
    switch (status) {
    case "inProgress":
      return CorrectionStatus.inProgress;
    case "completed":
      return CorrectionStatus.completed;
    case "rejected":
      return CorrectionStatus.rejected;
    default:
      return CorrectionStatus.requested;
    }
  }
}
