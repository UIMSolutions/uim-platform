/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.push_notification;
// import uim.platform.mobile.application.usecases.manage.push_notifications;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;


import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class PushNotificationController : ManageController {
  private ManagePushNotificationsUseCase usecase;

  this(ManagePushNotificationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/push/notifications", &handleSend);
    router.get("/api/v1/push/notifications", &handleList);
    router.get("/api/v1/push/notifications/*", &handleGet);
    router.delete_("/api/v1/push/notifications/*", &handleDelete);
  }

  protected void handleSend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      SendPushNotificationRequest r;
      r.tenantId = tenantId;
      r.appId = j.getString("appId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.payload = j.getString("payload");
      r.provider = j.getString("provider");
      r.priority = j.getString("priority");
      r.targetDevices = getStrings(j, "targetDevices");
      r.targetTopics = getStrings(j, "targetTopics");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = UserId(j.getString("createdBy"));
      auto result = usecase.send(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Push notification sent successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto results = usecase.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("title", item.title)
          .set("provider", item.provider)
          .set("status", item.status);
      }
      auto resp = Json.emptyObject
        .set("items", items);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = precheck.id;
      auto result = usecase.get(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", Json(result.data.id))
          .set("tenantId", Json(result.data.tenantId))
          .set("appId", Json(result.data.appId))
          .set("title", Json(result.data.title))
          .set("body", Json(result.data.body_))
          .set("payload", Json(result.data.payload))
          .set("provider", Json(result.data.provider))
          .set("priority", Json(result.data.priority))
          .set("targetDevices", toJsonArray(result.data.targetDevices))
          .set("targetTopics", toJsonArray(result.data.targetTopics))
          .set("scheduledAt", Json(result.data.scheduledAt))
          .set("expiresAt", Json(result.data.expiresAt))
          .set("status", Json(result.data.status))
          .set("createdBy", Json(result.data.createdBy))
          .set("message", "Push notification retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = PushNotificationprecheck.id);
      auto result = usecase.deletePushNotification(id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        res.writeBody("", 204);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
