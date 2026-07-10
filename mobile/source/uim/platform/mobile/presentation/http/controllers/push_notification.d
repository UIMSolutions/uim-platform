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

// mixin(Showmodule!());

@safe:
class PushNotificationController : ManageHttpController {
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

  protected Json sendHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    SendPushNotificationRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.title = data.getString("title");
    r.body_ = data.getString("body");
    r.payload = data.getString("payload");
    r.provider = data.getString("provider");
    r.priority = data.getString("priority");
    r.targetDevices = data.getStrings("targetDevices");
    r.targetTopics = data.getStrings("targetTopics");
    r.scheduledAt = data.getLong("scheduledAt");
    r.expiresAt = data.getLong("expiresAt");
    r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.send(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Push notification sent successfully", "Created", 201, resp);
  }

  mixin(HandleTemplate!("handleSend", "sendHandler"));

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto results = usecase.listNotifications(tenantId);
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
      .set("items", items)
      .set("totalCount", Json(results.length));

    return successResponse("Push notifications retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto notification = usecase.getNotification(tenantId, id);
    if (notification.isNull)
      return errorResponse("Push notification not found", 400);
      
    auto resp = Json.emptyObject
      .set("id", notification.id)
      .set("tenantId", notification.tenantId)
      .set("appId", notification.appId)
      .set("title", notification.title)
      .set("body", notification.body_)
      .set("payload", notification.payload)
      .set("provider", notification.provider)
      .set("priority", notification.priority)
      .set("targetDevices", toJsonArray(notification.targetDevices))
      .set("targetTopics", toJsonArray(notification.targetTopics))
      .set("scheduledAt", notification.scheduledAt)
      .set("expiresAt", notification.expiresAt)
      .set("status", notification.status)
      .set("createdBy", notification.createdBy)
      .set("message", "Push notification retrieved successfully");

    return successResponse("Push notification retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PushNotificationId(precheck.id);
    auto result = usecase.deleteNotification(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    return successResponse("Push notification deleted successfully", "Deleted", 204, Json
        .emptyObject.set("id", result.id));

  }
}
