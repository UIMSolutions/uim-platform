module uim.platform.identity_authentication.presentation.http.channel;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_channels;
import application.dto;
import domain.types;
import domain.entities.channel;
import uim.platform.identity_authentication.presentation.http.json_utils;

class ChannelController
{
    private ManageChannelsUseCase useCase;

    this(ManageChannelsUseCase useCase)
    {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/channels", &handleCreate);
        router.get("/api/v1/channels", &handleList);
        router.get("/api/v1/channels/*", &handleGet);
        router.put("/api/v1/channels/*", &handleUpdate);
        router.delete_("/api/v1/channels/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateChannelRequest();
            r.workspaceId = j.getString("workspaceId");
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");

            auto ctStr = j.getString("channelType");
            if (ctStr == "notification") r.channelType = ChannelType.notification;
            else if (ctStr == "custom") r.channelType = ChannelType.custom;
            else if (ctStr == "external") r.channelType = ChannelType.external;
            else r.channelType = ChannelType.activity;

            r.config = parseChannelConfig(j);

            auto result = useCase.createChannel(r);
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
            auto channels = useCase.listByWorkspace(workspaceId, tenantId);
            auto arr = Json.emptyArray;
            foreach (ref c; channels)
                arr ~= serializeChannel(c);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) channels.length);
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
            auto ch = useCase.getChannel(id, tenantId);
            if (ch is null)
            {
                writeError(res, 404, "Channel not found");
                return;
            }
            res.writeJsonBody(serializeChannel(*ch), 200);
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
            auto j = req.json;
            auto r = UpdateChannelRequest();
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.active = j.getBoolean("active", true);
            r.config = parseChannelConfig(j);

            auto result = useCase.updateChannel(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            useCase.deleteChannel(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private ChannelConfig parseChannelConfig(Json j)
{
    import domain.entities.channel : ChannelConfig;
    ChannelConfig cfg;
    auto v = "config" in j;
    if (v !is null && (*v).type == Json.Type.object)
    {
        auto c = *v;
        cfg.sourceUrl = jsonStr(c, "sourceUrl");
        cfg.pollIntervalSec = jsonInt(c, "pollIntervalSec");
        cfg.authType = jsonStr(c, "authType");
        cfg.authToken = jsonStr(c, "authToken");
        cfg.maxItems = jsonInt(c, "maxItems");
    }
    return cfg;
}

private Json serializeChannel(ref Channel c)
{
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["workspaceId"] = Json(c.workspaceId);
    j["tenantId"] = Json(c.tenantId);
    j["name"] = Json(c.name);
    j["description"] = Json(c.description);
    j["channelType"] = Json(c.channelType.to!string);
    j["active"] = Json(c.active);
    j["createdAt"] = Json(c.createdAt);
    j["updatedAt"] = Json(c.updatedAt);

    auto cfg = Json.emptyObject;
    cfg["sourceUrl"] = Json(c.config.sourceUrl);
    cfg["pollIntervalSec"] = Json(c.config.pollIntervalSec);
    cfg["authType"] = Json(c.config.authType);
    cfg["maxItems"] = Json(c.config.maxItems);
    j["config"] = cfg;

    return j;
}
