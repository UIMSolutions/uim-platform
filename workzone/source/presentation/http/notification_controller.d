module uim.platform.identity_authentication.presentation.http.notification;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_notifications;
import application.dto;
import domain.types;
import domain.entities.notification;
import uim.platform.identity_authentication.presentation.http.json_utils;

class NotificationController
{
    private ManageNotificationsUseCase useCase;

    this(ManageNotificationsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/notifications", &handleCreate);
        router.get("/api/v1/notifications", &handleList);
        router.get("/api/v1/notifications/*", &handleGet);
        router.put("/api/v1/notifications/read/*", &handleMarkRead);
        router.put("/api/v1/notifications/dismiss/*", &handleDismiss);
        router.delete_("/api/v1/notifications/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateNotificationRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.recipientId = j.getString("recipientId");
            r.title = j.getString("title");
            r.body_ = j.getString("body");
            r.sourceApp = j.getString("sourceApp");
            r.sourceObjectType = j.getString("sourceObjectType");
            r.sourceObjectId = j.getString("sourceObjectId");
            r.actionUrl = j.getString("actionUrl");
            r.expiresAt = jsonLong(j, "expiresAt");

            auto pStr = j.getString("priority");
            if (pStr == "low") r.priority = NotificationPriority.low;
            else if (pStr == "high") r.priority = NotificationPriority.high;
            else if (pStr == "critical") r.priority = NotificationPriority.critical;
            else r.priority = NotificationPriority.medium;

            auto result = useCase.createNotification(r);
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
            auto recipientId = req.params.get("recipientId", "");
            auto unreadOnly = req.params.get("unread", "") == "true";

            Notification[] items;
            if (unreadOnly)
                items = useCase.listUnread(recipientId, tenantId);
            else
                items = useCase.listByRecipient(recipientId, tenantId);

            auto arr = Json.emptyArray;
            foreach (ref n; items)
                arr ~= serializeNotification(n);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
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
            auto n = useCase.getNotification(id, tenantId);
            if (n is null)
            {
                writeError(res, 404, "Notification not found");
                return;
            }
            res.writeJsonBody(serializeNotification(*n), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleMarkRead(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = useCase.markAsRead(id, tenantId);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("read");
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

    private void handleDismiss(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto result = useCase.dismiss(id, tenantId);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("dismissed");
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
            useCase.deleteNotification(id, tenantId);
            res.writeBody("", 204);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }
}

private Json serializeNotification(ref Notification n)
{
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(n.id);
    j["tenantId"] = Json(n.tenantId);
    j["recipientId"] = Json(n.recipientId);
    j["title"] = Json(n.title);
    j["body"] = Json(n.body_);
    j["sourceApp"] = Json(n.sourceApp);
    j["sourceObjectType"] = Json(n.sourceObjectType);
    j["sourceObjectId"] = Json(n.sourceObjectId);
    j["actionUrl"] = Json(n.actionUrl);
    j["priority"] = Json(n.priority.to!string);
    j["status"] = Json(n.status.to!string);
    j["createdAt"] = Json(n.createdAt);
    j["readAt"] = Json(n.readAt);
    j["expiresAt"] = Json(n.expiresAt);
    return j;
}
