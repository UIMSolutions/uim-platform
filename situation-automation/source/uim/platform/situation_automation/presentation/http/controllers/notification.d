/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.notification;

// import uim.platform.situation_automation.application.usecases.manage.usecase;
// import uim.platform.situation_automation.application.dto;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

class NotificationController : PlatformController {
    private ManageNotificationsUseCase usecase;

    this(ManageNotificationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/situation-automation/usecase", &handleList);
        router.get("/api/v1/situation-automation/usecase/*", &handleGet);
        router.post("/api/v1/situation-automation/usecase", &handleCreate);
        router.put("/api/v1/situation-automation/usecase/*", &handleUpdate);
        router.delete_("/api/v1/situation-automation/usecase/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateNotificationRequest r;
            r.tenantId = tenantId;
            r.situationInstanceId = SituationInstanceId(j.getString("instanceId"));
            r.notificationId = NotificationId(j.getString("id"));
            r.recipientId = j.getString("recipientId");
            r.title = j.getString("title");
            r.message = j.getString("message");
            r.channel = j.getString("channel");
            r.priority = j.getString("priority");
            r.actionUrl = j.getString("actionUrl");

            auto result = usecase.createNotification(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Notification created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto notifications = usecase.listNotifications(tenantId);

            auto jarr = Json.emptyArray;
            foreach (n; notifications) {
                jarr ~= Json.emptyObject
                    .set("id", n.id)
                    .set("instanceId", n.situationInstanceId.value)
                    .set("recipientId", n.recipientId)
                    .set("title", n.title)
                    .set("channel", n.channel.to!string)
                    .set("status", n.status.to!string)
                    .set("priority", n.priority.to!string)
                    .set("createdAt", n.createdAt)
                    .set("sentAt", n.sentAt);
            }

            auto resp = Json.emptyObject
                .set("count", notifications.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto notificationId = NotificationId(extractIdFromPath(req.requestURI.to!string));
            auto n = usecase.getNotification(tenantId, notificationId);
            if (n.isNull) {
                writeError(res, 404, "Notification not found");
                return;
            }

            auto resp = Json.emptyObject
                .set("id", n.id)
                .set("instanceId", n.situationInstanceId.value)
                .set("recipientId", n.recipientId)
                .set("title", n.title)
                .set("message", n.message)
                .set("channel", n.channel.to!string)
                .set("status", n.status.to!string)
                .set("priority", n.priority.to!string)
                .set("actionUrl", n.actionUrl)
                .set("createdAt", n.createdAt)
                .set("sentAt", n.sentAt)
                .set("readAt", n.readAt)
                .set("message", "Notification retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {

            auto tenantId = req.getTenantId;
            auto j = req.json;
            
            UpdateNotificationRequest r;
            r.tenantId = tenantId;
            r.notificationId = NotificationId(extractIdFromPath(req.requestURI.to!string));
            r.status = j.getString("status");

            auto result = usecase.updateNotification(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Notification updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto notificationId = NotificationId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteNotification(tenantId, notificationId);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Notification deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
