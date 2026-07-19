/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.channel;

// import uim.platform.monitoring.application.usecases.manage.notification_channels;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;
mixin(ShowModule!());

@safe:
class ChannelController : ManageHttpController {
  private ManageNotificationChannelsUseCase usecase;

  this(ManageNotificationChannelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
    router.put("/api/v1/channels/*", &handleUpdate);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateNotificationChannelRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.channelType = data.getString("channelType");
    r.emailRecipients = data.getStrings("emailRecipients");
    r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
    r.webhookUrl = data.getString("webhookUrl");
    r.webhookSecret = data.getString("webhookSecret");
    r.webhookMethod = data.getString("webhookMethod");
    r.onPremiseHost = data.getString("onPremiseHost");
    r.onPremisePort = data.getInteger("onPremisePort");
    r.onPremiseProtocol = data.getString("onPremiseProtocol");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createChannel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Notification channel created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto channels = usecase.listChannels(tenantId);
    auto arr = channels.map!(channel => channel.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(channels.length));

    return successResponse("Notification channels retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NotificationChannelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid notification channel ID", 400);

    auto ch = usecase.getChannel(tenantId, id);
    if (ch.isNull)
      return errorResponse("Notification channel not found", 404);

    auto responseData = ch.toJson();
    return successResponse("Notification channel retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NotificationChannelId(precheck.id);
    auto data = precheck.data;

    UpdateNotificationChannelRequest r;
    r.tenantId = tenantId;
    r.channelId = id;
    r.description = data.getString("description");
    r.state = data.getString("state");
    r.emailRecipients = data.getStrings("emailRecipients");
    r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
    r.webhookUrl = data.getString("webhookUrl");
    r.webhookSecret = data.getString("webhookSecret");
    r.onPremiseHost = data.getString("onPremiseHost");
    r.onPremisePort = data.getInteger("onPremisePort");
    r.onPremiseProtocol = data.getString("onPremiseProtocol");

    auto result = usecase.updateChannel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Notification channel updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = NotificationChannelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid notification channel ID", 400);

    auto result = usecase.deleteChannel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Notification channel deleted successfully", "Deleted", 200, responseData);
  }
}
