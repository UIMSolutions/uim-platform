/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.channel;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.monitoring.application.usecases.manage.notification_channels;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class ChannelController : PlatformController {
  private ManageNotificationChannelsUseCase uc;

  this(ManageNotificationChannelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGetById);
    router.put("/api/v1/channels/*", &handleUpdate);
    router.delete_("/api/v1/channels/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateNotificationChannelRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.channelType = j.getString("channelType");
      r.emailRecipients = getStringArray(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.webhookMethod = j.getString("webhookMethod");
      r.onPremiseHost = j.getString("onPremiseHost");
      r.onPremisePort = j.getInteger("onPremisePort");
      r.onPremiseProtocol = j.getString("onPremiseProtocol");
      r.createdBy = req.headers.get("X-User-Id", "");

      auto result = uc.createChannel(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Notification channel created");

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
      auto channels = uc.listChannels(tenantId);

      auto arr = Json.emptyArray;
      foreach (channel; channels)
        arr ~= serializeChannel(channel);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(channels.length));

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto ch = uc.getChannel(id);
      if (ch.isNull) {
        writeError(res, 404, "Notification channel not found");
        return;
      }
      res.writeJsonBody(serializeChannel(ch), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateNotificationChannelRequest r;
      r.description = j.getString("description");
      r.state = j.getString("state");
      r.emailRecipients = getStringArray(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.onPremiseHost = j.getString("onPremiseHost");
      r.onPremisePort = j.getInteger("onPremisePort");
      r.onPremiseProtocol = j.getString("onPremiseProtocol");

      auto result = uc.updateChannel(id, r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, result.error == "Notification channel not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteChannel(id);
      if (result.success) {
        auto response = Json.emptyObject
          .set("deleted", Json(true));

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeChannel(const ref NotificationChannel channel) {
    return Json.emptyObject
      .set("id", channel.id)
      .set("tenantId", channel.tenantId)
      .set("name", channel.name)
      .set("description", channel.description)
      .set("channelType", channel.channelType.to!string)
      .set("state", channel.state.to!string)
      .set("emailRecipients", channel.emailRecipients)
      .set("emailSubjectPrefix", channel.emailSubjectPrefix)
      .set("webhookUrl", channel.webhookUrl)
      .set("webhookMethod", channel.webhookMethod)
      .set("onPremiseHost", channel.onPremiseHost)
      .set("onPremisePort", channel.onPremisePort)
      .set("onPremiseProtocol", channel.onPremiseProtocol)
      .set("createdBy", channel.createdBy)
      .set("createdAt", channel.createdAt)
      .set("updatedAt", channel.updatedAt);
  }
}
