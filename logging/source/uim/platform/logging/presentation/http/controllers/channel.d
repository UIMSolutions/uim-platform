/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.channel;
// import uim.platform.logging.application.usecases.manage.notification_channels;
// import uim.platform.logging.application.dto;
// 
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class ChannelController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
 
      CreateNotificationChannelRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.channelType = data.getString("channelType");
      r.emailRecipients = getStrings(j, "emailRecipients");
      r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
      r.webhookUrl = data.getString("webhookUrl");
      r.webhookSecret = data.getString("webhookSecret");
      r.webhookMethod = data.getString("webhookMethod");
      r.slackWebhookUrl = data.getString("slackWebhookUrl");
      r.slackChannel = data.getString("slackChannel");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = usecase.createChannel(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);
        
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
      auto tenantId = precheck.tenantId;

      auto channels = usecase.listChannels(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ch; channels) {
        jarr ~= Json.emptyObject
          .set("id", ch.id)
          .set("name", ch.name)
          .set("description", ch.description);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", Json(channels.length))
        .set("message", "Notification channels retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      

      auto id = NotificationChannelprecheck.id);
      auto ch = usecase.getChannel(tenantId, id);
      if (ch.isNull) {
        writeError(res, 404, "Notification channel not found");
        return;
      }

      auto cj = Json.emptyObject
      .set("id", ch.id)
      .set("name", ch.name)
      .set("description", ch.description) ;

      res.writeJsonBody(cj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = NotificationChannelprecheck.id);
      auto data = precheck.data;
      UpdateNotificationChannelRequest r;
      r.channelId = id;
      r.tenantId = tenantId;
      r.description = data.getString("description");
      r.state = data.getString("state");
      r.emailRecipients = getStrings(j, "emailRecipients");
      r.emailSubjectPrefix = data.getString("emailSubjectPrefix");
      r.webhookUrl = data.getString("webhookUrl");
      r.webhookSecret = data.getString("webhookSecret");
      r.slackWebhookUrl = data.getString("slackWebhookUrl");
      r.slackChannel = data.getString("slackChannel");

      auto result = usecase.updateChannel(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto channelId = NotificationChannelprecheck.id);

      usecase.deleteChannel(tenantId, channelId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
