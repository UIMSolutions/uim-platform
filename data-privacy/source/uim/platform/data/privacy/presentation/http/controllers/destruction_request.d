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
class DestructionRequestController : ManageController {
  private ManageDestructionRequestsUseCase usecase;

  this(ManageDestructionRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/destruction-requests", &handleCreate);
    router.get("/api/v1/destruction-requests", &handleList);
    router.get("/api/v1/destruction-requests/*", &handleGet);
    router.put("/api/v1/destruction-requests/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/destruction-requests/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateDestructionRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
      r.requestedBy = UserId(j.getString("requestedBy"));
      r.targetSystems = getStrings(j, "targetSystems");
      r.archiveRequestId = j.getString("archiveRequestId");
      r.blockingRequestId = j.getString("blockingRequestId");
      r.reason = j.getString("reason");
      r.scheduledAt = jsonLong(j, "scheduledAt");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Destruction request created successfully");
            
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
        .set("totalCount", items.length);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DestructionRequestId(precheck.id);

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Destruction request not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      UpdateDestructionStatusRequest r;
      r.requestId = DestructionRequestId(precheck.id);
      r.tenantId = tenantId;
      r.status = j.getString("status");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Destruction request status updated successfully");
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DestructionRequestId(precheck.id);

      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
