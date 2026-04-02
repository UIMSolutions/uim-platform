module uim.platform.connectivity.presentation.http.controllers.connector;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.connectivity.application.usecases.manage_destinations;
import uim.platform.connectivity.application.dto;
import uim.platform.connectivity.domain.entities.destination;
import uim.platform.connectivity.presentation.http.json_utils;

class DestinationController {
    private ManageDestinationsUseCase uc;

    this(ManageDestinationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/destinations", &handleCreate);
        router.get("/api/v1/destinations", &handleList);
        router.get("/api/v1/destinations/*", &handleGetById);
        router.put("/api/v1/destinations/*", &handleUpdate);
        router.delete_("/api/v1/destinations/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = CreateDestinationRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.url = j.getString("url");
            r.destinationType = j.getString("type");
            r.authType = j.getString("authentication");
            r.proxyType = j.getString("proxyType");
            r.user = j.getString("user");
            r.password = j.getString("password");
            r.clientId = j.getString("clientId");
            r.clientSecret = j.getString("clientSecret");
            r.tokenServiceUrl = j.getString("tokenServiceURL");
            r.tokenServiceUser = j.getString("tokenServiceUser");
            r.tokenServicePassword = j.getString("tokenServicePassword");
            r.certificateId = j.getString("certificateId");
            r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");
            r.properties = parseProperties(j);
            r.additionalHeaders = parseHeaders(j);

            auto result = uc.createDestination(r);
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
            auto dests = uc.listDestinations(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref d; dests)
                arr ~= serializeDest(d);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)dests.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto dest = uc.getDestination(id);
            if (dest.id.length == 0) {
                writeError(res, 404, "Destination not found");
                return;
            }
            res.writeJsonBody(serializeDest(dest), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            auto r = UpdateDestinationRequest();
            r.description = j.getString("description");
            r.url = j.getString("url");
            r.authType = j.getString("authentication");
            r.proxyType = j.getString("proxyType");
            r.user = j.getString("user");
            r.password = j.getString("password");
            r.clientId = j.getString("clientId");
            r.clientSecret = j.getString("clientSecret");
            r.tokenServiceUrl = j.getString("tokenServiceURL");
            r.tokenServiceUser = j.getString("tokenServiceUser");
            r.tokenServicePassword = j.getString("tokenServicePassword");
            r.certificateId = j.getString("certificateId");
            r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");
            r.properties = parseProperties(j);
            r.additionalHeaders = parseHeaders(j);

            auto result = uc.updateDestination(id, r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, result.error == "Destination not found" ? 404 : 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteDestination(id);
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

    private static Json serializeDest(ref const Destination d) {
        auto j = Json.emptyObject;
        j["id"] = Json(d.id);
        j["tenantId"] = Json(d.tenantId);
        j["name"] = Json(d.name);
        j["description"] = Json(d.description);
        j["url"] = Json(d.url);
        j["type"] = Json(d.destinationType.to!string);
        j["authentication"] = Json(d.authType.to!string);
        j["proxyType"] = Json(d.proxyType.to!string);
        j["cloudConnectorLocationId"] = Json(d.cloudConnectorLocationId);

        if (d.properties.length > 0) {
            auto props = Json.emptyArray;
            foreach (ref p; d.properties) {
                auto pj = Json.emptyObject;
                pj["key"] = Json(p.key);
                pj["value"] = Json(p.value);
                props ~= pj;
            }
            j["properties"] = props;
        }

        if (d.additionalHeaders.length > 0) {
            auto hdrs = Json.emptyArray;
            foreach (ref h; d.additionalHeaders) {
                auto hj = Json.emptyObject;
                hj["key"] = Json(h.key);
                hj["value"] = Json(h.value);
                hdrs ~= hj;
            }
            j["additionalHeaders"] = hdrs;
        }

        j["createdBy"] = Json(d.createdBy);
        j["createdAt"] = Json(d.createdAt);
        j["updatedAt"] = Json(d.updatedAt);
        return j;
    }

    private static DestinationProperty[] parseProperties(Json j) {
        DestinationProperty[] result;
        auto v = "properties" in j;
        if (v is null || (*v).type != Json.Type.array)
            return result;
        foreach (item; *v) {
            if (item.type == Json.Type.object)
                result ~= DestinationProperty(item.getString("key"), item.getString("value"));
        }
        return result;
    }

    private static DestinationProperty[] parseHeaders(Json j) {
        DestinationProperty[] result;
        auto v = "additionalHeaders" in j;
        if (v is null || (*v).type != Json.Type.array)
            return result;
        foreach (item; *v) {
            if (item.type == Json.Type.object)
                result ~= DestinationProperty(item.getString("key"), item.getString("value"));
        }
        return result;
    }
}
