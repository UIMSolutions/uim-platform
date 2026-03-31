module presentation.http.blocking_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_blocking_requests;
import application.dto;
import domain.types;
import domain.entities.blocking_request;
import presentation.http.json_utils;

class BlockingController
{
    private ManageBlockingRequestsUseCase uc;

    this(ManageBlockingRequestsUseCase uc) { this.uc = uc; }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/blocking-requests", &handleCreate);
        router.get("/api/v1/blocking-requests", &handleList);
        router.get("/api/v1/blocking-requests/*", &handleGetById);
        router.put("/api/v1/blocking-requests/*", &handleUpdateStatus);
        router.delete_("/api/v1/blocking-requests/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateBlockingRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.dataSubjectId = jsonStr(j, "dataSubjectId");
            r.requestedBy = jsonStr(j, "requestedBy");
            r.targetSystems = jsonStrArray(j, "targetSystems");
            r.reason = jsonStr(j, "reason");

            auto result = uc.createRequest(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto statusParam = req.headers.get("X-Status-Filter", "");

            BlockingRequest[] items;
            if (statusParam.length > 0)
                items = uc.listByStatus(tenantId, parseBlockingStatus(statusParam));
            else
                items = uc.listRequests(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref e; items)
                arr ~= serialize(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto entry = uc.getRequest(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Blocking request not found");
                return;
            }
            res.writeJsonBody(serialize(*entry), 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            UpdateBlockingStatusRequest r;
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.status = parseBlockingStatus(jsonStr(j, "status"));

            auto result = uc.updateStatus(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            uc.deleteRequest(id, tenantId);
            res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private static Json serialize(ref const BlockingRequest e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["dataSubjectId"] = Json(e.dataSubjectId);
        j["requestedBy"] = Json(e.requestedBy);
        j["status"] = Json(e.status.to!string);
        j["reason"] = Json(e.reason);
        j["requestedAt"] = Json(e.requestedAt);
        j["activatedAt"] = Json(e.activatedAt);
        j["releasedAt"] = Json(e.releasedAt);

        auto systems = Json.emptyArray;
        foreach (ref s; e.targetSystems)
            systems ~= Json(s);
        j["targetSystems"] = systems;

        auto cats = Json.emptyArray;
        foreach (ref c; e.categories)
            cats ~= Json(c.to!string);
        j["categories"] = cats;

        return j;
    }

    private static BlockingStatus parseBlockingStatus(string s)
    {
        switch (s)
        {
            case "active": return BlockingStatus.active;
            case "released": return BlockingStatus.released;
            default: return BlockingStatus.requested;
        }
    }
}
