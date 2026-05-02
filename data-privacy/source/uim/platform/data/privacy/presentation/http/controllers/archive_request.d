/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.archive_request;

// import uim.platform.data.privacy.application.usecases.manage.archive_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.archive_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ArchiveRequestController : PlatformController {
  private ManageArchiveRequestsUseCase uc;

  this(ManageArchiveRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/archive-requests", &handleCreate);
    router.get("/api/v1/archive-requests", &handleList);
    router.get("/api/v1/archive-requests/*", &handleGetById);
    router.put("/api/v1/archive-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/archive-requests/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateArchiveRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = getStringArray(j, "targetSystems");
      r.categories = getStringArray(j, "categories");
      r.archiveLocation = j.getString("archiveLocation");
      r.reason = j.getString("reason");
      r.isTestMode = j.getBoolean("isTestMode", false);
      r.scheduledAt = jsonLong(j, "scheduledAt");

      auto result = uc.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Archive request created");

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

      auto arr = items.MAP!(e => serialize(e)).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Archive requests retrieved successfully");

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
        writeError(res, 404, "Archive request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateArchiveStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.status = parseArchiveStatus(j.getString("status"));

      auto result = uc.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Archive request status updated");

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

  private static Json serialize(const ArchiveRequest e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("requestedBy", e.requestedBy)
      .set("status", e.status.to!string)
      .set("archiveLocation", e.archiveLocation)
      .set("reason", e.reason)
      .set("isTestMode", e.isTestMode)
      .set("scheduledAt", e.scheduledAt)
      .set("startedAt", e.startedAt)
      .set("completedAt", e.completedAt);
  }

  private static ArchiveStatus parseArchiveStatus(string status) {
    switch (status) {
    case "inProgress":
      return ArchiveStatus.inProgress;
    case "completed":
      return ArchiveStatus.completed;
    case "failed":
      return ArchiveStatus.failed;
    default:
      return ArchiveStatus.scheduled;
    }
  }
}
