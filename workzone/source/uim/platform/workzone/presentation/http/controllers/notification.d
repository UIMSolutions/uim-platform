module uim.platform.workzone.presentation.http.controllers.notification;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class NotificationController : ManageHttpController {
  private ManageNotificationsUseCase useCase;

  this(ManageNotificationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/notifications", &handleList);
    router.get("/api/v1/notifications/*", &handleGet);
    router.post("/api/v1/notifications", &handleCreate);
    router.put("/api/v1/notifications/*", &handleUpdate);
    router.delete_("/api/v1/notifications/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto data = precheck.data;
    CreateNotificationRequest r;
    r.tenantId = precheck.tenantId;
    r.recipientId = UserId(data.getString("recipientId"));
    r.title = data.getString("title");
    r.body_ = data.getString("body");
    r.sourceApp = data.getString("sourceApp");
    r.sourceObjectType = data.getString("sourceObjectType");
    r.sourceObjectId = data.getString("sourceObjectId");
    r.actionUrl = data.getString("actionUrl");
    r.priority = toNotificationPriority(data.getString("priority", "medium"));
    r.expiresAt = data.getLong("expiresAt", 0);

    auto result = useCase.createNotification(r);
    if (!result.success)
      return errorResponse(result.message, 400);

    return successResponse("Notification created successfully", "Created", 201,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto recipientIdRaw = req.query.get("recipientId", "");
    if (recipientIdRaw.length == 0)
      return errorResponse("recipientId query parameter is required", 400);

    Notification[] resources = [];req.query.get("unread", "0") == "1"
      ? resources = useCase.listUnreadNotifications(precheck.tenantId, UserId(recipientIdRaw))
      : resources = useCase.listNotifications(precheck.tenantId, UserId(recipientIdRaw));

    auto payload = resources.map!(n => n.toJson()).array.toJson;

    return successResponse("Notifications retrieved successfully", "Retrieved", 200,
      Json.emptyObject
        .set("count", resources.length)
        .set("resources", payload));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto entity = useCase.getNotification(precheck.tenantId, NotificationId(precheck.id));
    if (entity.isNull)
      return errorResponse("Notification not found", 404);

    return successResponse("Notification retrieved successfully", "Retrieved", 200, entity.toJson());
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto status = precheck.data.getString("status", "");
    CommandResult result;
    if (status == "read")
      result = useCase.markNotificationAsRead(precheck.tenantId, NotificationId(precheck.id));
    else if (status == "dismissed")
      result = useCase.dismissNotification(precheck.tenantId, NotificationId(precheck.id));
    else
      return errorResponse("Supported status values: read, dismissed", 400);

    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Notification updated successfully", "Updated", 200,
      Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto result = useCase.deleteNotification(precheck.tenantId, NotificationId(precheck.id));
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Notification deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
  }
}
