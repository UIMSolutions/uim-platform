/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.blocking_request;

// import uim.platform.data.privacy.application.usecases.manage.blocking_requests;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.blocking_request;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BlockingController : ManageController {
  private ManageBlockingRequestsUseCase usecase;

  this(ManageBlockingRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/blocking-requests", &handleCreate);
    router.get("/api/v1/blocking-requests", &handleList);
    router.get("/api/v1/blocking-requests/*", &handleGet);
    router.put("/api/v1/blocking-requests/*", &handleUpdateStatus);
    router.delete_("/api/v1/blocking-requests/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateBlockingRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = data.getString("dataSubjectId");
      r.requestedBy = data.getString("requestedBy");
      r.targetSystems = data.getStrings("targetSystems");
      r.reason = data.getString("reason");

      auto result = usecase.createRequest(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Blocking request created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto statusParam = req.headers.get("X-Status-Filter", "");

      BlockingRequest[] items = statusParam.length > 0
        ? usecase.listByStatus(tenantId, parseBlockingStatus(statusParam)) : usecase.listRequests(
          tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Blocking requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = BlockingRequestId(precheck.id);

      auto entry = usecase.getRequest(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Blocking request not found");
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
      UpdateBlockingStatusRequest r;
      r.id = BlockingRequestId(precheck.id);
      r.tenantId = tenantId;
      r.status = data.getString("status");

      auto result = usecase.updateStatus(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Blocking request status updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = BlockingRequestId(precheck.id);

      usecase.deleteRequest(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static BlockingStatus parseBlockingStatus(string status) {
    switch (status) {
    case "active":
      return BlockingStatus.active;
    case "released":
      return BlockingStatus.released;
    default:
      return BlockingStatus.requested;
    }
  }
}
