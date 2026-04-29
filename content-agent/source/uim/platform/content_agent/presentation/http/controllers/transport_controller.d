/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.transport_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.content_agent.application.usecases.manage.transport_requests;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.transport_request;
// import uim.platform.content_agent.domain.types;
// import uim.platform.content_agent.presentation.http.json_utils;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class TransportController : PlatformController {
  private ManageTransportRequestsUseCase uc;

  this(ManageTransportRequestsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/transports", &handleCreate);
    router.get("/api/v1/transports", &handleList);
    router.get("/api/v1/transports/*", &handleGetById);
    router.post("/api/v1/transports/release", &handleRelease);
    router.post("/api/v1/transports/cancel", &handleCancel);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateTransportRequest();
      r.tenantId = req.getTenantId;
      r.sourceSubaccount = j.getString("sourceSubaccount");
      r.targetSubaccount = j.getString("targetSubaccount");
      r.description = j.getString("description");
      r.mode = j.getString("mode");
      r.packageIds = getStringArray(j, "packageIds");
      r.queueId = j.getString("queueId");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createTransportRequest(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Transport request created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto transports = uc.listTransportRequests(tenantId);

      auto arr = Json.emptyArray;
      foreach (t; transports)
        arr ~= serializeTransport(t);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(transports.length))
        .set("message", "Transport requests retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tr = uc.getTransportRequest(id);
      if (tr.id.isEmpty) {
        writeError(res, 404, "Transport request not found");
        return;
      }
      res.writeJsonBody(serializeTransport(tr), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = ReleaseTransportRequest();
      r.requestId = j.getString("requestId");
      r.tenantId = req.getTenantId;
      r.releasedBy = req.headers.get("X-User-Id", "");

      auto result = uc.releaseTransport(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "released")
          .set("message", "Transport request released successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto requestId = j.getString("requestId");

      auto result = uc.cancelTransport(requestId);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "cancelled")
          .set("message", "Transport request cancelled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeTransport(const TransportRequest t) {
    return Json.emptyObject
      .set("id", t.id)
      .set("tenantId", t.tenantId)
      .set("sourceSubaccount", t.sourceSubaccount)
      .set("targetSubaccount", t.targetSubaccount)
      .set("description", t.description)
      .set("status", t.status.to!string)
      .set("mode", t.mode.to!string)
      .set("queueId", t.queueId)
      .set("createdBy", t.createdBy)
      .set("createdAt", t.createdAt)
      .set("updatedAt", t.updatedAt)
      .set("releasedAt", t.releasedAt)
      .set("errorMessage", t.errorMessage)
      .set("packageIds", toJsonArray(t.packageIds));
  }
}
