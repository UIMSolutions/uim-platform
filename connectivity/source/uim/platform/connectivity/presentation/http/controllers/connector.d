/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.connector;




// import uim.platform.connectivity.application.usecases.manage.connectors;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class ConnectorController : ManageController {
  private ManageConnectorsUseCase usecase;

  this(ManageConnectorsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/connectors", &handleRegister);
    router.get("/api/v1/connectors", &handleList);
    router.get("/api/v1/connectors/*", &handleGet);
    router.post("/api/v1/connectors/*/heartbeat", &handleHeartbeat);
    router.delete_("/api/v1/connectors/*", &handleUnregister);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = RegisterConnectorRequest();
      r.subaccountId = data.getString("subaccountId");
      r.tenantId = tenantId;
      r.locationId = data.getString("locationId");
      r.description = data.getString("description");
      r.connectorVersion = data.getString("connectorVersion");
      r.host = data.getString("host");
      r.port = getUshort(j, "port");
      r.tunnelEndpoint = data.getString("tunnelEndpoint");

      auto result = usecase.registerConnector(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Connector registered successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto conns = usecase.listByTenant(tenantId);

      auto arr = conns.map!(c => c.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(conns.length))
        .set("message", "Connectors retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ConnectorId(precheck.id);
      auto cc = usecase.getConnector(tenantId, id);
      if (cc.isNull) {
        writeError(res, 404, "Connector not found");
        return;
      }
      res.writeJsonBody(cc.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleHeartbeat(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      // Extract connector id from /api/v1/connectors/{id}/heartbeat
      auto uri = req.requestURI;
      auto parts = splitPath(uri);
      if (parts.length < 5) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto connectorId = ConnectorId(parts[$ - 2]); // second-to-last segment before "heartbeat"

      auto data = precheck.data;
      auto r = HeartbeatRequest();
      auto tenantId = precheck.tenantId;
      r.connectorVersion = data.getString("connectorVersion");

      auto result = usecase.heartbeat(tenantId, connectorId, r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("status", "acknowledged")
          .set("message", "Heartbeat received");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUnregister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ConnectorId(precheck.id);
      auto result = usecase.unregister(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Connector unregistered successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
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
