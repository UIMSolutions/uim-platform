/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.notification;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.workzone.application.usecases.manage.notifications;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.notification;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class NotificationController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateNotificationRequest();
      r.tenantId = req.getTenantId;
      r.recipientId = j.getString("recipientId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.sourceApp = j.getString("sourceApp");
      r.sourceObjectType = j.getString("sourceObjectType");
      r.sourceObjectId = j.getString("sourceObjectId");
      r.actionUrl = j.getString("actionUrl");
      r.expiresAt = jsonLong(j, "expiresAt");

      auto pStr = j.getString("priority");
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
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
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

  private void handleMarkRead(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.markAsRead(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "read")
          .set("message", "Notification marked as read");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDismiss(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.dismiss(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
        .set("status", "dismissed")
        .set("message", "Notification dismissed successfully");
        
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
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
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
