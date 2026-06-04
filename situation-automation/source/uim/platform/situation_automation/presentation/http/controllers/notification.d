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

class NotificationController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateNotificationRequest r;
            r.tenantId = precheck.tenantId;
            r.situationInstanceId = SituationInstanceId(data.getString("instanceId"));
            r.notificationId = NotificationId(precheck.id);
            r.recipientId = data.getString("recipientId");
            r.title = data.getString("title");
            r.message = data.getString("message");
            r.channel = data.getString("channel");
            r.priority = data.getString("priority");
            r.actionUrl = data.getString("actionUrl");

            auto result = usecase.createNotification(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Notification created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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
                .set("resources", list);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto notificationId = NotificationId(precheck.id);
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

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            
            UpdateNotificationRequest r;
            r.tenantId = precheck.tenantId;
            r.notificationId = NotificationId(precheck.id);
            r.status = data.getString("status");

            auto result = usecase.updateNotification(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Notification updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto notificationId = NotificationId(precheck.id);

            auto result = usecase.deleteNotification(tenantId, notificationId);
            if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Notification deleted successfully", 200, responseData);
            
    }
}
