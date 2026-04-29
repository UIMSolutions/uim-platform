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
class CorrectionRequestController : PlatformController {
  private ManageCorrectionRequestsUseCase uc;

  this(ManageCorrectionRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/correction-requests", &handleCreate);
    router.get("/api/v1/correction-requests", &handleList);
    router.get("/api/v1/correction-requests/*", &handleGetById);
    router.put("/api/v1/correction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/correction-requests/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateCorrectionRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = getStringArray(j, "targetSystems");
      r.fieldName = j.getString("fieldName");
      r.currentValue = j.getString("currentValue");
      r.correctedValue = j.getString("correctedValue");
      r.reason = j.getString("reason");

      auto result = uc.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Correction request created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listRequests(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Correction requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Correction request not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateCorrectionStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.status = parseCorrectionStatus(j.getString("status"));

      auto result = uc.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Correction request status updated successfully");

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
      uc.deleteRequest(tenantId, id);
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
