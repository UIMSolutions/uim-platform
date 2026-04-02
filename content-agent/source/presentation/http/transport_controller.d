module uim.platform.content_agent.presentation.http.transport;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.content_agent.application.usecases.manage_transport_requests;
import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.transport_request;
import uim.platform.content_agent.domain.types;
import presentation.http.json_utils;

class TransportController
{
    private ManageTransportRequestsUseCase uc;

    this(ManageTransportRequestsUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/transports", &handleCreate);
        router.get("/api/v1/transports", &handleList);
        router.get("/api/v1/transports/*", &handleGetById);
        router.post("/api/v1/transports/release", &handleRelease);
        router.post("/api/v1/transports/cancel", &handleCancel);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateTransportRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.sourceSubaccount = j.getString("sourceSubaccount");
            r.targetSubaccount = j.getString("targetSubaccount");
            r.description = j.getString("description");
            r.mode = j.getString("mode");
            r.packageIds = jsonStrArray(j, "packageIds");
            r.queueId = j.getString("queueId");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createTransportRequest(r);
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
            auto transports = uc.listTransportRequests(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref t; transports)
                arr ~= serializeTransport(t);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) transports.length);
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
            auto tr = uc.getTransportRequest(id);
            if (tr.id.length == 0)
            {
                writeError(res, 404, "Transport request not found");
                return;
            }
            res.writeJsonBody(serializeTransport(tr), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleRelease(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = ReleaseTransportRequest();
            r.requestId = j.getString("requestId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.releasedBy = req.headers.get("X-User-Id", "");

            auto result = uc.releaseTransport(r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["status"] = Json("released");
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

    private void handleCancel(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto requestId = j.getString("requestId");

            auto result = uc.cancelTransport(requestId);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["status"] = Json("cancelled");
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

    private static Json serializeTransport(ref const TransportRequest t)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(t.id);
        j["tenantId"] = Json(t.tenantId);
        j["sourceSubaccount"] = Json(t.sourceSubaccount);
        j["targetSubaccount"] = Json(t.targetSubaccount);
        j["description"] = Json(t.description);
        j["status"] = Json(t.status.to!string);
        j["mode"] = Json(t.mode.to!string);
        j["queueId"] = Json(t.queueId);
        j["createdBy"] = Json(t.createdBy);
        j["createdAt"] = Json(t.createdAt);
        j["updatedAt"] = Json(t.updatedAt);
        j["releasedAt"] = Json(t.releasedAt);
        j["errorMessage"] = Json(t.errorMessage);
        j["packageIds"] = toJsonArray(t.packageIds);
        return j;
    }
}
