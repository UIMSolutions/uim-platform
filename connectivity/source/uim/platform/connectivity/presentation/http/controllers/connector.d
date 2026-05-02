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

// import uim.platform.connectivity.application.usecases.manage.connectors;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class ConnectorController : PlatformController {
  private ManageConnectorsUseCase usecase;

  this(ManageConnectorsUseCase usecase) {
    this.usecase = usecase;
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

      auto result = usecase.registerConnector(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

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
      auto conns = usecase.listByTenant(tenantId);

      auto arr = conns.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(conns.length));
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = ConnectorId(extractIdFromPath(req.requestURI));
      auto cc = usecase.getConnector(id);
      if (cc.isNull) {
        writeError(res, 404, "Connector not found");
        return;
      }
      res.writeJsonBody(cc.toJson, 200);
    } catch (Exception e) {
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

      auto result = usecase.heartbeat(connectorId, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("status", "acknowledged");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUnregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = ConnectorId(extractIdFromPath(req.requestURI));
      auto result = usecase.unregister(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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
