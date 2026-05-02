/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.deletion;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.deletion_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.deletion_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DeletionController : PlatformController {
  private ManageDeletionRequestsUseCase uc;

  this(ManageDeletionRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deletion-requests", &handleCreate);
    router.get("/api/v1/deletion-requests", &handleList);
    router.get("/api/v1/deletion-requests/*", &handleGetById);
    router.put("/api/v1/deletion-requests/*", &handleUpdateStatus);
    router.delete_("/api/v1/deletion-requests/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDeletionRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = getStringArray(j, "targetSystems");
      r.reason = j.getString("reason");

      auto result = uc.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Deletion request created successfully");
            
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto statusParam = req.headers.get("X-Status-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      DeletionRequest[] items;
      if (statusParam.length > 0)
        items = uc.listByStatus(tenantId, parseDeletionStatus(statusParam));
      else if (subjectParam.length > 0)
        items = uc.listByDataSubject(tenantId, subjectParam);
      else
        items = uc.listRequests(tenantId);

      auto arr = items.map!(e => e.toJson).array;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Deletion requests retrieved successfully");

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
        writeError(res, 404, "Deletion request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDeletionStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.status = parseDeletionStatus(j.getString("status"));
      r.blockerReason = j.getString("blockerReason");

      auto result = uc.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Deletion request status updated successfully");

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

  private static Json serialize(const DeletionRequest e) {
    auto systems = e.targetSystems.map!(s => Json(s)).array;
    auto cats = e.categories.map!(c => Json(c.to!string)).array;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("requestedBy", e.requestedBy)
      .set("requestType", e.requestType.to!string)
      .set("status", e.status.to!string)
      .set("reason", e.reason)
      .set("blockerReason", e.blockerReason)
      .set("requestedAt", e.requestedAt)
      .set("completedAt", e.completedAt)
      .set("deadline", e.deadline)
      .set("targetSystems", systems)
      .set("categories", cats);
  }

  private static DeletionStatus parseDeletionStatus(string status) {
    switch (status) {
    case "inProgress":
      return DeletionStatus.inProgress;
    case "completed":
      return DeletionStatus.completed;
    case "failed":
      return DeletionStatus.failed;
    case "blocked":
      return DeletionStatus.blocked;
    default:
      return DeletionStatus.requested;
    }
  }
}
