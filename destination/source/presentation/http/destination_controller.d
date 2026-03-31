module presentation.http.destination_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_destinations;
import application.dto;
import domain.entities.destination;
import domain.types;
import presentation.http.json_utils;

class DestinationController
{
    private ManageDestinationsUseCase uc;

    this(ManageDestinationsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/destinations", &handleCreate);
        router.get("/api/v1/destinations", &handleList);
        router.get("/api/v1/destinations/*", &handleGetById);
        router.put("/api/v1/destinations/*", &handleUpdate);
        router.delete_("/api/v1/destinations/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateDestinationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.subaccountId = req.headers.get("X-Subaccount-Id", "");
            r.serviceInstanceId = jsonStr(j, "serviceInstanceId");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.destinationType = jsonStr(j, "type");
            r.url = jsonStr(j, "url");
            r.authenticationType = jsonStr(j, "authentication");
            r.proxyType = jsonStr(j, "proxyType");
            r.level = jsonStr(j, "level");
            r.urlPath = jsonStr(j, "urlPath");
            r.httpMethod = jsonStr(j, "httpMethod");

            r.user = jsonStr(j, "user");
            r.password = jsonStr(j, "password");
            r.clientId = jsonStr(j, "clientId");
            r.clientSecret = jsonStr(j, "clientSecret");
            r.tokenServiceUrl = jsonStr(j, "tokenServiceURL");
            r.tokenServiceUser = jsonStr(j, "tokenServiceUser");
            r.tokenServicePassword = jsonStr(j, "tokenServicePassword");
            r.audience = jsonStr(j, "audience");
            r.systemUser = jsonStr(j, "systemUser");
            r.samlAudience = jsonStr(j, "samlAudience");
            r.nameIdFormat = jsonStr(j, "nameIdFormat");
            r.authnContextClassRef = jsonStr(j, "authnContextClassRef");

            r.keystoreId = jsonStr(j, "keystoreId");
            r.keystorePassword = jsonStr(j, "keystorePassword");
            r.truststoreId = jsonStr(j, "truststoreId");

            r.locationId = jsonStr(j, "locationId");
            r.sccVirtualHost = jsonStr(j, "sccVirtualHost");
            r.sccVirtualPort = jsonInt(j, "sccVirtualPort");

            r.properties = jsonStrMap(j, "properties");
            r.fragmentIds = jsonStrArray(j, "fragmentIds");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.create(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto subaccountId = req.headers.get("X-Subaccount-Id", "");
            auto instanceId = req.params.get("serviceInstanceId");

            Destination[] destinations;
            if (instanceId.length > 0)
                destinations = uc.listByServiceInstance(tenantId, instanceId);
            else
                destinations = uc.listBySubaccount(tenantId, subaccountId);

            auto arr = Json.emptyArray;
            foreach (ref d; destinations)
                arr ~= serializeDestination(d);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) destinations.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto d = uc.getDestination(id);
            if (d.id.length == 0)
            {
                writeError(res, 404, "Destination not found");
                return;
            }
            res.writeJsonBody(serializeDestination(d), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateDestinationRequest r;
            r.description = jsonStr(j, "description");
            r.url = jsonStr(j, "url");
            r.authenticationType = jsonStr(j, "authentication");
            r.proxyType = jsonStr(j, "proxyType");
            r.user = jsonStr(j, "user");
            r.password = jsonStr(j, "password");
            r.clientId = jsonStr(j, "clientId");
            r.clientSecret = jsonStr(j, "clientSecret");
            r.tokenServiceUrl = jsonStr(j, "tokenServiceURL");
            r.tokenServiceUser = jsonStr(j, "tokenServiceUser");
            r.tokenServicePassword = jsonStr(j, "tokenServicePassword");
            r.audience = jsonStr(j, "audience");
            r.keystoreId = jsonStr(j, "keystoreId");
            r.keystorePassword = jsonStr(j, "keystorePassword");
            r.truststoreId = jsonStr(j, "truststoreId");
            r.locationId = jsonStr(j, "locationId");
            r.sccVirtualHost = jsonStr(j, "sccVirtualHost");
            r.sccVirtualPort = jsonInt(j, "sccVirtualPort");
            r.status = jsonStr(j, "status");
            r.properties = jsonStrMap(j, "properties");
            r.fragmentIds = jsonStrArray(j, "fragmentIds");

            auto result = uc.updateDestination(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Destination not found" ? 404 : 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.removeDestination(id);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeDestination(const ref Destination d)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(d.id);
        j["tenantId"] = Json(d.tenantId);
        j["subaccountId"] = Json(d.subaccountId);
        j["serviceInstanceId"] = Json(d.serviceInstanceId);
        j["name"] = Json(d.name);
        j["description"] = Json(d.description);
        j["type"] = Json(d.destinationType.to!string);
        j["url"] = Json(d.url);
        j["authentication"] = Json(d.authenticationType.to!string);
        j["proxyType"] = Json(d.proxyType.to!string);
        j["level"] = Json(d.level.to!string);
        j["status"] = Json(d.status.to!string);
        j["locationId"] = Json(d.locationId);
        j["properties"] = toJsonObject(d.properties);
        j["fragmentIds"] = toJsonArray(d.fragmentIds);
        j["createdBy"] = Json(d.createdBy);
        j["createdAt"] = Json(d.createdAt);
        j["modifiedAt"] = Json(d.modifiedAt);
        return j;
    }
}
