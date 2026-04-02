module uim.platform.content_agent.presentation.http.queue;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.content_agent.application.usecases.manage_transport_queues;
import uim.platform.content_agent.application.dto;
import uim.platform.content_agent.domain.entities.transport_queue;
import uim.platform.content_agent.domain.types;
import presentation.http.json_utils;

class QueueController
{
    private ManageTransportQueuesUseCase uc;

    this(ManageTransportQueuesUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/queues", &handleCreate);
        router.get("/api/v1/queues", &handleList);
        router.get("/api/v1/queues/*", &handleGetById);
        router.put("/api/v1/queues/*", &handleUpdate);
        router.delete_("/api/v1/queues/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateQueueRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.queueType = j.getString("queueType");
            r.endpoint = j.getString("endpoint");
            r.authToken = j.getString("authToken");
            r.isDefault = j.getBoolean("isDefault");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createQueue(r);
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
            auto queues = uc.listQueues(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref q; queues)
                arr ~= serializeQueue(q);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) queues.length);
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
            auto queue = uc.getQueue(id);
            if (queue.id.length == 0)
            {
                writeError(res, 404, "Queue not found");
                return;
            }
            res.writeJsonBody(serializeQueue(queue), 200);
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
            auto r = UpdateQueueRequest();
            r.description = j.getString("description");
            r.endpoint = j.getString("endpoint");
            r.authToken = j.getString("authToken");
            r.isDefault = j.getBoolean("isDefault");

            auto result = uc.updateQueue(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Queue not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteQueue(id);
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

    private static Json serializeQueue(ref const TransportQueue q)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(q.id);
        j["tenantId"] = Json(q.tenantId);
        j["name"] = Json(q.name);
        j["description"] = Json(q.description);
        j["queueType"] = Json(q.queueType.to!string);
        j["endpoint"] = Json(q.endpoint);
        j["isDefault"] = Json(q.isDefault);
        j["createdBy"] = Json(q.createdBy);
        j["createdAt"] = Json(q.createdAt);
        j["updatedAt"] = Json(q.updatedAt);
        return j;
    }
}
