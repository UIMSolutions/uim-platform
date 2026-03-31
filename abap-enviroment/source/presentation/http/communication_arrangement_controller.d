module presentation.http.communication_arrangement_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_communication_arrangements;
import application.dto;
import domain.entities.communication_arrangement;
import domain.types;
import presentation.http.json_utils;

class CommunicationArrangementController
{
    private ManageCommunicationArrangementsUseCase uc;

    this(ManageCommunicationArrangementsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/communication-arrangements", &handleCreate);
        router.get("/api/v1/communication-arrangements", &handleList);
        router.get("/api/v1/communication-arrangements/*", &handleGetById);
        router.put("/api/v1/communication-arrangements/*", &handleUpdate);
        router.delete_("/api/v1/communication-arrangements/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateCommunicationArrangementRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.systemInstanceId = jsonStr(j, "systemInstanceId");
            r.scenarioId = jsonStr(j, "scenarioId");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.direction = jsonStr(j, "direction");
            r.authMethod = jsonStr(j, "authMethod");
            r.communicationUser = jsonStr(j, "communicationUser");
            r.communicationPassword = jsonStr(j, "communicationPassword");
            r.clientId = jsonStr(j, "clientId");
            r.clientSecret = jsonStr(j, "clientSecret");
            r.tokenEndpoint = jsonStr(j, "tokenEndpoint");
            r.certificateId = jsonStr(j, "certificateId");

            auto result = uc.createArrangement(r);
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
            auto systemId = req.headers.get("X-System-Id", "");
            auto arrangements = uc.listArrangements(systemId);
            auto arr = Json.emptyArray;
            foreach (ref a; arrangements)
                arr ~= serializeArrangement(a);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) arrangements.length);
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
            auto arrangement = uc.getArrangement(id);
            if (arrangement is null)
            {
                writeError(res, 404, "Communication arrangement not found");
                return;
            }
            res.writeJsonBody(serializeArrangement(*arrangement), 200);
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
            UpdateCommunicationArrangementRequest r;
            r.description = jsonStr(j, "description");
            r.status = jsonStr(j, "status");
            r.authMethod = jsonStr(j, "authMethod");
            r.communicationUser = jsonStr(j, "communicationUser");
            r.communicationPassword = jsonStr(j, "communicationPassword");
            r.clientId = jsonStr(j, "clientId");
            r.clientSecret = jsonStr(j, "clientSecret");
            r.tokenEndpoint = jsonStr(j, "tokenEndpoint");

            auto result = uc.updateArrangement(id, r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
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
            auto result = uc.deleteArrangement(id);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("deleted");
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

    private static Json serializeArrangement(ref const CommunicationArrangement a)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(a.id);
        j["tenantId"] = Json(a.tenantId);
        j["systemInstanceId"] = Json(a.systemInstanceId);
        j["scenarioId"] = Json(a.scenarioId);
        j["name"] = Json(a.name);
        j["description"] = Json(a.description);
        j["direction"] = Json(a.direction.to!string);
        j["status"] = Json(a.status.to!string);
        j["authMethod"] = Json(a.authMethod.to!string);
        j["communicationUser"] = Json(a.communicationUser);
        j["createdAt"] = Json(a.createdAt);
        j["updatedAt"] = Json(a.updatedAt);
        return j;
    }
}
