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
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DestructionRequestController : PlatformController {
  private ManageDestructionRequestsUseCase usecase;

  this(ManageDestructionRequestsUseCase usecase) {
    this.usecase = usecase;
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
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.requestedBy = UserId(j.getString("requestedBy"));
      r.targetSystems = getStrings(j, "targetSystems");
      r.archiveRequestId = ArchiveRequestId(j.getString("archiveRequestId"));
      r.blockingRequestId = BlockingRequestId(j.getString("blockingRequestId"));
      r.reason = j.getString("reason");
      r.scheduledAt = jsonLong(j, "scheduledAt");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Destruction request created successfully");
            
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = usecase.listRequests(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = DestructionRequestId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Destruction request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDestructionStatusRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;
      r.status = parseDestructionStatus(j.getString("status"));

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destruction request status updated successfully");
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = DestructionRequestId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const DestructionRequest e) {
    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("requestedBy", e.requestedBy)
      .set("status", e.status.to!string)
      .set("archiveRequestId", e.archiveRequestId)
      .set("blockingRequestId", e.blockingRequestId)
      .set("reason", e.reason)
      .set("scheduledAt", e.scheduledAt)
      .set("startedAt", e.startedAt)
      .set("completedAt", e.completedAt);
  }

  private static DestructionStatus parseDestructionStatus(string status) {
    switch (status) {
      case "inProgress": return DestructionStatus.inProgress;
      case "completed": return DestructionStatus.completed;
      case "failed": return DestructionStatus.failed;
      default: return DestructionStatus.scheduled;
    }
  }
}
