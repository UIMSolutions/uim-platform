module presentation.http.channel_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_notification_channels;
import application.dto;
import domain.entities.notification_channel;
import domain.types;
import presentation.http.json_utils;

class ChannelController
{
    private ManageNotificationChannelsUseCase uc;

    this(ManageNotificationChannelsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/channels", &handleCreate);
        router.get("/api/v1/channels", &handleList);
        router.get("/api/v1/channels/*", &handleGetById);
        router.put("/api/v1/channels/*", &handleUpdate);
        router.delete_("/api/v1/channels/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateNotificationChannelRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.channelType = jsonStr(j, "channelType");
            r.emailRecipients = jsonStrArray(j, "emailRecipients");
            r.emailSubjectPrefix = jsonStr(j, "emailSubjectPrefix");
            r.webhookUrl = jsonStr(j, "webhookUrl");
            r.webhookSecret = jsonStr(j, "webhookSecret");
            r.webhookMethod = jsonStr(j, "webhookMethod");
            r.onPremiseHost = jsonStr(j, "onPremiseHost");
            r.onPremisePort = jsonInt(j, "onPremisePort");
            r.onPremiseProtocol = jsonStr(j, "onPremiseProtocol");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.createChannel(r);
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
            auto channels = uc.listChannels(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref ch; channels)
                arr ~= serializeChannel(ch);

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

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto ch = uc.getChannel(id);
            if (ch.id.length == 0)
            {
                writeError(res, 404, "Notification channel not found");
                return;
            }
            res.writeJsonBody(serializeChannel(ch), 200);
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
            UpdateNotificationChannelRequest r;
            r.description = jsonStr(j, "description");
            r.state = jsonStr(j, "state");
            r.emailRecipients = jsonStrArray(j, "emailRecipients");
            r.emailSubjectPrefix = jsonStr(j, "emailSubjectPrefix");
            r.webhookUrl = jsonStr(j, "webhookUrl");
            r.webhookSecret = jsonStr(j, "webhookSecret");
            r.onPremiseHost = jsonStr(j, "onPremiseHost");
            r.onPremisePort = jsonInt(j, "onPremisePort");

            auto result = uc.updateChannel(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Notification channel not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteChannel(id);
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

    private static Json serializeChannel(const ref NotificationChannel ch)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(ch.id);
        j["tenantId"] = Json(ch.tenantId);
        j["name"] = Json(ch.name);
        j["description"] = Json(ch.description);
        j["channelType"] = Json(ch.channelType.to!string);
        j["state"] = Json(ch.state.to!string);
        j["emailRecipients"] = toJsonArray(ch.emailRecipients);
        j["emailSubjectPrefix"] = Json(ch.emailSubjectPrefix);
        j["webhookUrl"] = Json(ch.webhookUrl);
        j["webhookMethod"] = Json(ch.webhookMethod);
        j["onPremiseHost"] = Json(ch.onPremiseHost);
        j["onPremisePort"] = Json(cast(long) ch.onPremisePort);
        j["onPremiseProtocol"] = Json(ch.onPremiseProtocol);
        j["createdBy"] = Json(ch.createdBy);
        j["createdAt"] = Json(ch.createdAt);
        j["updatedAt"] = Json(ch.updatedAt);
        return j;
    }
}
