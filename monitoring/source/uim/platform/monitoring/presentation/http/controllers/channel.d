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
// import uim.platform.monitoring.presentation.http.json_utils;
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
      r.emailRecipients = jsonStrArray(j, "emailRecipients");
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
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      foreach (ch; channels)
        arr ~= serializeChannel(ch);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(channels.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto ch = uc.getChannel(id);
      if (ch.id.isEmpty) {
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
      r.emailRecipients = jsonStrArray(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.onPremiseHost = j.getString("onPremiseHost");
      r.onPremisePort = j.getInteger("onPremisePort");
      rManageNotificationChannelsUseCase.onPremiseProtocol = j.getString("onPremiseProtocol");

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

  private static Json serializeChannel(const ref NotificationChannel ch) {
    return Json.emptyObject
      .set("id", ch.id)
      .set("tenantId", ch.tenantId)
      .set("name", ch.name)
      .set("description", ch.description)
      .set("channelType", ch.channelType.to!string)
      .set("state", ch.state.to!string)
      .set("emailRecipients", ch.emailRecipients)
      .set("emailSubjectPrefix", ch.emailSubjectPrefix)
      .set("webhookUrl", ch.webhookUrl)
      .set("webhookMethod", ch.webhookMethod)
      .set("onPremiseHost", ch.onPremiseHost)
      .set("onPremisePort", ch.onPremisePort)
      .set("onPremiseProtocol", ch.onPremiseProtocol)
      .set("createdBy", ch.createdBy)
      .set("createdAt", ch.createdAt)
      .set("updatedAt", ch.updatedAt);
  }
}
