module uim.platform.connectivity.presentation.http.controllers.connector;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.connectivity.application.usecases.manage_connectors;
import uim.platform.connectivity.application.dto;
import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity.presentation.http.json_utils;

class ConnectorController {
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
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.locationId = j.getString("locationId");
            r.description = j.getString("description");
            r.connectorVersion = j.getString("connectorVersion");
            r.host = j.getString("host");
            r.port = jsonUshort(j, "port");
            r.tunnelEndpoint = j.getString("tunnelEndpoint");

            auto result = uc.registerConnector(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto conns = uc.listByTenant(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref c; conns)
                arr ~= serializeConnector(c);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)conns.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto cc = uc.getConnector(id);
            if (cc.id.length == 0) {
                writeError(res, 404, "Connector not found");
                return;
            }
            res.writeJsonBody(serializeConnector(cc), 200);
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

            auto result = uc.heartbeat(connectorId, r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["status"] = Json("acknowledged");
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
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.unregister(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeConnector(ref const CloudConnector c) {
        auto j = Json.emptyObject;
        j["id"] = Json(c.id);
        j["subaccountId"] = Json(c.subaccountId);
        j["tenantId"] = Json(c.tenantId);
        j["locationId"] = Json(c.locationId);
        j["description"] = Json(c.description);
        j["connectorVersion"] = Json(c.connectorVersion);
        j["host"] = Json(c.host);
        j["port"] = Json(cast(long)c.port);
        j["status"] = Json(c.status.to!string);
        j["tunnelEndpoint"] = Json(c.tunnelEndpoint);
        j["lastHeartbeat"] = Json(c.lastHeartbeat);
        j["connectedSince"] = Json(c.connectedSince);
        j["createdAt"] = Json(c.createdAt);
        j["updatedAt"] = Json(c.updatedAt);
        return j;
    }

    private static string[] splitPath(string uri) {
        import std.string : indexOf, split;

        auto qpos = uri.indexOf('?');
        string path = qpos >= 0 ? uri[0 .. qpos] : uri;
        string[] parts;
        foreach (seg; path.split("/"))
            if (seg.length > 0)
                parts ~= seg;
        return parts;
    }
}
