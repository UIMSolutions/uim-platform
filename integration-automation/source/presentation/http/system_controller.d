module presentation.http.system_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_systems;
import application.dto;
import domain.types;
import domain.entities.system_connection;
import presentation.http.json_utils;
import presentation.http.scenario_controller : parseSystemType;

class SystemController
{
    private ManageSystemsUseCase useCase;

    this(ManageSystemsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/systems", &handleCreate);
        router.get("/api/v1/systems", &handleList);
        router.get("/api/v1/systems/*", &handleGetById);
        router.put("/api/v1/systems/*", &handleUpdate);
        router.delete_("/api/v1/systems/*", &handleDelete);
        router.post("/api/v1/systems/test/*", &handleTestConnection);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateSystemRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.systemType = parseSystemType(jsonStr(j, "systemType"));
            r.host = jsonStr(j, "host");
            r.port = jsonUshort(j, "port");
            r.client = jsonStr(j, "client");
            r.protocol = jsonStr(j, "protocol");
            r.environment = jsonStr(j, "environment");
            r.region = jsonStr(j, "region");
            r.systemId = jsonStr(j, "systemId");
            r.tenant = jsonStr(j, "tenant");
            r.createdBy = jsonStr(j, "createdBy");

            auto result = useCase.createSystem(r);
            if (result.isSuccess())
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
            auto systems = useCase.listSystems(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref s; systems)
                arr ~= serializeSystem(s);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) systems.length);
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto sys = useCase.getSystem(id, tenantId);
            if (sys is null)
            {
                writeError(res, 404, "System not found");
                return;
            }
            res.writeJsonBody(serializeSystem(*sys), 200);
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
            auto r = UpdateSystemRequest();
            r.id = id;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.systemType = parseSystemType(jsonStr(j, "systemType"));
            r.host = jsonStr(j, "host");
            r.port = jsonUshort(j, "port");
            r.client = jsonStr(j, "client");
            r.protocol = jsonStr(j, "protocol");
            r.status = parseConnectionStatus(jsonStr(j, "status"));
            r.environment = jsonStr(j, "environment");
            r.region = jsonStr(j, "region");
            r.systemId = jsonStr(j, "systemId");
            r.tenant = jsonStr(j, "tenant");

            auto result = useCase.updateSystem(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = useCase.deleteSystem(id, tenantId);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
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

    private void handleTestConnection(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = useCase.testConnection(id, tenantId);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["connectionStatus"] = Json("active");
                res.writeJsonBody(resp, 200);
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

    private static Json serializeSystem(ref const SystemConnection s)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(s.id);
        j["tenantId"] = Json(s.tenantId);
        j["name"] = Json(s.name);
        j["description"] = Json(s.description);
        j["systemType"] = Json(s.systemType.to!string);
        j["host"] = Json(s.host);
        j["port"] = Json(cast(long) s.port);
        j["client"] = Json(s.client);
        j["protocol"] = Json(s.protocol);
        j["status"] = Json(s.status.to!string);
        j["environment"] = Json(s.environment);
        j["region"] = Json(s.region);
        j["systemId"] = Json(s.systemId);
        j["tenant"] = Json(s.tenant);
        j["createdBy"] = Json(s.createdBy);
        j["createdAt"] = Json(s.createdAt);
        j["updatedAt"] = Json(s.updatedAt);
        return j;
    }
}

ConnectionStatus parseConnectionStatus(string s)
{
    switch (s)
    {
        case "active": return ConnectionStatus.active;
        case "inactive": return ConnectionStatus.inactive;
        case "error": return ConnectionStatus.error;
        case "testing": return ConnectionStatus.testing;
        default: return ConnectionStatus.inactive;
    }
}
