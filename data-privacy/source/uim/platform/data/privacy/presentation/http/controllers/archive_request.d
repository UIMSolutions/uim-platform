/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.archive_request;

import uim.platform.data.privacy.application.usecases.manage.archive_requests;
import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.archive_request;

class ArchiveRequestController {
  private ManageArchiveRequestsUseCase uc;

  this(ManageArchiveRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = jsonStrArray(j, "targetSystems");
      r.categories = jsonStrArray(j, "categories");
      r.archiveLocation = j.getString("archiveLocation");
      r.reason = j.getString("reason");
      r.isTestMode = j.getBoolean("isTestMode", false);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto entry = uc.getRequest(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Archive request not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateArchiveStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.status = parseArchiveStatus(j.getString("status"));

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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      uc.deleteRequest(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const ArchiveRequest e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["dataSubjectId"] = Json(e.dataSubjectId);
    j["requestedBy"] = Json(e.requestedBy);
    j["status"] = Json(e.status.to!string);
    j["archiveLocation"] = Json(e.archiveLocation);
    j["reason"] = Json(e.reason);
    j["isTestMode"] = Json(e.isTestMode);
    j["scheduledAt"] = Json(e.scheduledAt);
    j["startedAt"] = Json(e.startedAt);
    j["completedAt"] = Json(e.completedAt);
    return j;
  }

  private static ArchiveStatus parseArchiveStatus(string s) {
    switch (s) {
      case "inProgress": return ArchiveStatus.inProgress;
      case "completed": return ArchiveStatus.completed;
      case "failed": return ArchiveStatus.failed;
      default: return ArchiveStatus.scheduled;
    }
  }
}
