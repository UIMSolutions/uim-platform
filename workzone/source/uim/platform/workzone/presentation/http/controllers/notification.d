/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.notification;



// import uim.platform.workzone.application.usecases.manage.notifications;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.notification;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class NotificationController : ManageController {
  private ManageNotificationsUseCase useCase;

  this(ManageNotificationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/notifications", &handleCreate);
    router.get("/api/v1/notifications", &handleList);
    router.get("/api/v1/notifications/*", &handleGet);
    router.put("/api/v1/notifications/read/*", &handleMarkRead);
    router.put("/api/v1/notifications/dismiss/*", &handleDismiss);
    router.delete_("/api/v1/notifications/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateNotificationRequest();
      r.tenantId = tenantId;
      r.recipientId = data.getString("recipientId");
      r.title = data.getString("title");
      r.body_ = data.getString("body");
      r.sourceApp = data.getString("sourceApp");
      r.sourceObjectType = data.getString("sourceObjectType");
      r.sourceObjectId = data.getString("sourceObjectId");
      r.actionUrl = data.getString("actionUrl");
      r.expiresAt = jsonLong(j, "expiresAt");

      auto pStr = data.getString("priority");
      if (pStr == "low")
        r.priority = NotificationPriority.low;
      else if (pStr == "high")
        r.priority = NotificationPriority.high;
      else if (pStr == "critical")
        r.priority = NotificationPriority.critical;
      else
        r.priority = NotificationPriority.medium;

      auto result = useCase.createNotification(r);
      if (result.isSuccess()) {
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
      auto recipientId = req.params.get("recipientId", "");
      auto unreadOnly = req.params.get("unread", "") == "true";

      Notification[] items;
      if (unreadOnly)
        items = useCase.listUnread(tenantId, recipientId);
      else
        items = useCase.listByRecipient(tenantId, recipientId);

      auto arr = items.map!(n => n.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Notifications retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto n = useCase.getNotification(tenantId, id);
      if (n.isNull) {
        writeError(res, 404, "Notification not found");
        return;
      }
      res.writeJsonBody(n.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleMarkRead(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.markAsRead(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "read")
          .set("message", "Notification marked as read");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDismiss(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.dismiss(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("status", "dismissed")
        .set("message", "Notification dismissed successfully");
        
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
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      useCase.deleteNotification(tenantId, id);
      res.writeBody("", 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}

private Json serializeNotification(Notification n) {
  return Json.emptyObject
    .set("id", n.id)
    .set("tenantId", n.tenantId)
    .set("recipientId", n.recipientId)
    .set("title", n.title)
    .set("body", n.body_)
    .set("sourceApp", n.sourceApp)
    .set("sourceObjectType", n.sourceObjectType)
    .set("sourceObjectId", n.sourceObjectId)
    .set("actionUrl", n.actionUrl)
    .set("priority", n.priority.to!string)
    .set("status", n.status.to!string)
    .set("createdAt", n.createdAt)
    .set("readAt", n.readAt)
    .set("expiresAt", n.expiresAt);
}
