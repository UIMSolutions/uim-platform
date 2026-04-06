/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.notification;

import uim.platform.situation_automation.application.usecases.manage.notifications;
import uim.platform.situation_automation.application.dto;
import uim.platform.situation_automation.presentation.http.json_utils;

import uim.platform.situation_automation;

class NotificationController : SAPController {
    private ManageNotificationsUseCase uc;

    this(ManageNotificationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/situation-automation/notifications", &handleList);
        router.get("/api/v1/situation-automation/notifications/*", &handleGet);
        router.post("/api/v1/situation-automation/notifications", &handleCreate);
        router.put("/api/v1/situation-automation/notifications/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/notifications/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateNotificationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.instanceId = jsonStr(j, "instanceId");
            r.id = jsonStr(j, "id");
            r.recipientId = jsonStr(j, "recipientId");
            r.title = jsonStr(j, "title");
            r.message = jsonStr(j, "message");
            r.channel = jsonStr(j, "channel");
            r.priority = jsonStr(j, "priority");
            r.actionUrl = jsonStr(j, "actionUrl");

            auto result = uc.create(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Notification created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto notifications = uc.list(tenantId);

            auto jarr = Json.emptyArray;
            foreach (ref n; notifications) {
                auto nj = Json.emptyObject;
                nj["id"] = Json(n.id);
                nj["instanceId"] = Json(n.instanceId);
                nj["recipientId"] = Json(n.recipientId);
                nj["title"] = Json(n.title);
                nj["channel"] = Json(n.channel.to!string);
                nj["status"] = Json(n.status.to!string);
                nj["priority"] = Json(n.priority.to!string);
                nj["createdAt"] = Json(n.createdAt);
                nj["sentAt"] = Json(n.sentAt);
                jarr ~= nj;
            }

            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) notifications.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto n = uc.get_(id);
            if (n.id.length == 0) {
                writeError(res, 404, "Notification not found");
                return;
            }

            auto resp = Json.emptyObject;
            resp["id"] = Json(n.id);
            resp["instanceId"] = Json(n.instanceId);
            resp["recipientId"] = Json(n.recipientId);
            resp["title"] = Json(n.title);
            resp["message"] = Json(n.message);
            resp["channel"] = Json(n.channel.to!string);
            resp["status"] = Json(n.status.to!string);
            resp["priority"] = Json(n.priority.to!string);
            resp["actionUrl"] = Json(n.actionUrl);
            resp["createdAt"] = Json(n.createdAt);
            resp["sentAt"] = Json(n.sentAt);
            resp["readAt"] = Json(n.readAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto j = req.json;
            UpdateNotificationRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.id = extractIdFromPath(req.requestURI.to!string);
            r.status = jsonStr(j, "status");

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Notification updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Notification deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
