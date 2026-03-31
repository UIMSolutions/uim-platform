module uim.platform.identity_authentication.presentation.http.feed_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_feeds;
import application.dto;
import domain.types;
import domain.entities.feed_entry;
import uim.platform.identity_authentication.presentation.http.json_utils;

class FeedController
{
    private ManageFeedsUseCase useCase;

    this(ManageFeedsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/feeds", &handleCreate);
        router.get("/api/v1/feeds", &handleList);
        router.get("/api/v1/feeds/*", &handleGet);
        router.delete_("/api/v1/feeds/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateFeedEntryRequest();
            r.workspaceId = jsonStr(j, "workspaceId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.actorId = jsonStr(j, "actorId");
            r.actorName = jsonStr(j, "actorName");
            r.action = jsonStr(j, "action");
            r.objectType = jsonStr(j, "objectType");
            r.objectId = jsonStr(j, "objectId");
            r.objectTitle = jsonStr(j, "objectTitle");
            r.message = jsonStr(j, "message");

            auto result = useCase.createEntry(r);
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
            auto workspaceId = req.params.get("workspaceId", "");
            auto entries = useCase.listByWorkspace(workspaceId, tenantId);
            auto arr = Json.emptyArray;
            foreach (ref e; entries)
                arr ~= serializeFeed(e);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) entries.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto entry = useCase.getEntry(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Feed entry not found");
                return;
            }
            res.writeJsonBody(serializeFeed(*entry), 200);
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
            useCase.deleteEntry(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private Json serializeFeed(ref FeedEntry e)
{
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["workspaceId"] = Json(e.workspaceId);
    j["tenantId"] = Json(e.tenantId);
    j["actorId"] = Json(e.actorId);
    j["actorName"] = Json(e.actorName);
    j["action"] = Json(e.action);
    j["objectType"] = Json(e.objectType);
    j["objectId"] = Json(e.objectId);
    j["objectTitle"] = Json(e.objectTitle);
    j["message"] = Json(e.message);
    j["createdAt"] = Json(e.createdAt);
    return j;
}
