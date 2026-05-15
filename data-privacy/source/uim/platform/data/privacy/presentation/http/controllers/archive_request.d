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
  private ManageArchiveRequestsUseCase usecase;

  this(ManageArchiveRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/archive-requests", &handleCreate);
    router.get("/api/v1/archive-requests", &handleList);
    router.get("/api/v1/archive-requests/*", &handleGet);
    router.put("/api/v1/archive-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/archive-requests/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateArchiveRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.requestedBy = j.getString("requestedBy");
      r.targetSystems = j.getStrings("targetSystems");
      r.categories = j.getStrings("categories").map!(c => c.to!PersonalDataCategory).array;
      r.archiveLocation = j.getString("archiveLocation");
      r.reason = j.getString("reason");
      r.isTestMode = j.getBoolean("isTestMode", false);
      r.scheduledAt = j.getLong("scheduledAt");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Archive request created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto items = usecase.listRequests(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Archive requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ArchiveRequestId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Archive request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateArchiveStatusRequest r;
      r.id = ArchiveRequestId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.status = parseArchiveStatus(j.getString("status"));

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Archive request status updated");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ArchiveRequestId(extractIdFromPath(req.requestURI));

      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
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
