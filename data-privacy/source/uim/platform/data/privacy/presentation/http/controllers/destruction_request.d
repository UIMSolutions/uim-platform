/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.destruction_request;

// import uim.platform.data.privacy.application.usecases.manage.destruction_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.destruction_request;
// import uim.platform.data.privacy.presentation.http.json_utils;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DestructionRequestController : SAPController {
  private ManageDestructionRequestsUseCase uc;

  this(ManageDestructionRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destruction-requests", &handleCreate);
    router.get("/api/v1/destruction-requests", &handleList);
    router.get("/api/v1/destruction-requests/*", &handleGetById);
    router.put("/api/v1/destruction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/destruction-requests/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDestructionRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = jsonStrArray(j, "targetSystems");
      r.archiveRequestId = j.getString("archiveRequestId");
      r.blockingRequestId = j.getString("blockingRequestId");
      r.reason = j.getString("reason");
      r.scheduledAt = jsonLong(j, "scheduledAt");

      auto result = uc.createRequest(r);
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
      auto tenantId = req.getTenantId;
      auto items = uc.listRequests(tenantId);

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
      auto tenantId = req.getTenantId;
      auto entry = uc.getRequest(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Destruction request not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDestructionStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.status = parseDestructionStatus(j.getString("status"));

      auto result = uc.updateStatus(r);
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
      auto tenantId = req.getTenantId;
      uc.deleteRequest(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const DestructionRequest e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["dataSubjectId"] = Json(e.dataSubjectId);
    j["requestedBy"] = Json(e.requestedBy);
    j["status"] = Json(e.status.to!string);
    j["archiveRequestId"] = Json(e.archiveRequestId);
    j["blockingRequestId"] = Json(e.blockingRequestId);
    j["reason"] = Json(e.reason);
    j["scheduledAt"] = Json(e.scheduledAt);
    j["startedAt"] = Json(e.startedAt);
    j["completedAt"] = Json(e.completedAt);
    return j;
  }

  private static DestructionStatus parseDestructionStatus(string s) {
    switch (s) {
      case "inProgress": return DestructionStatus.inProgress;
      case "completed": return DestructionStatus.completed;
      case "failed": return DestructionStatus.failed;
      default: return DestructionStatus.scheduled;
    }
  }
}
