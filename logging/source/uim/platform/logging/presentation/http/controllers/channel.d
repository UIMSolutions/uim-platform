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

class ChannelController : PlatformController {
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

  protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
 
      CreateNotificationChannelRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.channelType = j.getString("channelType");
      r.emailRecipients = getStrings(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.webhookMethod = j.getString("webhookMethod");
      r.slackWebhookUrl = j.getString("slackWebhookUrl");
      r.slackChannel = j.getString("slackChannel");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.createChannel(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);
        
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

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

  protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      

      auto id = NotificationChannelId(extractIdFromPath(req.requestURI.to!string));
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

  protected void handleGetUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = NotificationChannelId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateNotificationChannelRequest r;
      r.channelId = id;
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.state = j.getString("state");
      r.emailRecipients = getStrings(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.slackWebhookUrl = j.getString("slackWebhookUrl");
      r.slackChannel = j.getString("slackChannel");

      auto result = usecase.updateChannel(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto channelId = NotificationChannelId(extractIdFromPath(req.requestURI.to!string));

      usecase.deleteChannel(tenantId, channelId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
