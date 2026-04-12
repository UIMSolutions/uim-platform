/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.connector;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.connectivity.application.usecases.manage.connectors;
import uim.platform.connectivity.application.dto;
import uim.platform.connectivity.domain.entities.cloud_connector;

class ConnectorController : PlatformController {
  private ManageConnectorsUseCase uc;

  this(ManageConnectorsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/connectors", &handleRegister);
    router.get("/api/v1/connectors", &handleList);
    router.get("/api/v1/connectors/*", &handleGetById);
    router.post("/api/v1/connectors/*/heartbeat", &handleHeartbeat);
    router.delete_("/api/v1/connectors/*", &handleUnregister);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = RegisterConnectorRequest();
      r.subaccountId = j.getString("subaccountId");
      r.tenantId = req.getTenantId;
      r.locationId = j.getString("locationId");
      r.description = j.getString("description");
      r.connectorVersion = j.getString("connectorVersion");
      r.host = j.getString("host");
      r.port = getUshort(j, "port");
      r.tunnelEndpoint = j.getString("tunnelEndpoint");

      auto result = uc.registerConnector(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto conns = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (c; conns)
        arr ~= serializeConnector(c);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(conns.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto cc = uc.getConnector(id);
      if (cc.id.isEmpty) {
        writeError(res, 404, "Connector not found");
        return;
      }
      res.writeJsonBody(serializeConnector(cc), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleHeartbeat(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // Extract connector id from /api/v1/connectors/{id}/heartbeat
      auto uri = req.requestURI;
      auto parts = splitPath(uri);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto connectorId = parts[$ - 2]; // second-to-last segment before "heartbeat"

      auto j = req.json;
      auto r = HeartbeatRequest();
      r.connectorVersion = j.getString("connectorVersion");

      auto result = uc.heartbeat(connectorId, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["status"] = Json("acknowledged");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUnregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.unregister(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeConnector(const CloudConnector c) {
    return Json.emptyObject
      .set("id", c.id)
      .set("subaccountId", c.subaccountId)
      .set("tenantId", c.tenantId)
      .set("locationId", c.locationId)
      .set("description", c.description)
      .set("connectorVersion", c.connectorVersion)
      .set("host", c.host)
      .set("port", c.port)
      .set("status", c.status.to!string)
      .set("tunnelEndpoint", c.tunnelEndpoint)
      .set("lastHeartbeat", c.lastHeartbeat)
      .set("connectedSince", c.connectedSince)
      .set("createdAt", c.createdAt)
      .set("updatedAt", c.updatedAt);
  }

  private static string[] splitPath(string uri) {
    // import std.string : indexOf, split;

    auto qpos = uri.indexOf('?');
    string path = qpos >= 0 ? uri[0 .. qpos] : uri;
    string[] parts;
    foreach (seg; path.split("/"))
      if (seg.length > 0)
        parts ~= seg;
    return parts;
  }
}
