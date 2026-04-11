/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.channel;

import uim.platform.logging.application.usecases.manage.notification_channels;
import uim.platform.logging.application.dto;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class ChannelController : PlatformController {
  private ManageNotificationChannelsUseCase uc;

  this(ManageNotificationChannelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/channels", &handleCreate);
    router.get("/api/v1/channels", &handleList);
    router.get("/api/v1/channels/*", &handleGet);
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
      r.slackWebhookUrl = j.getString("slackWebhookUrl");
      r.slackChannel = j.getString("slackChannel");
      r.createdBy = j.getString("createdBy");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto channels = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ch; channels) {
        auto cj = Json.emptyObject;
        cj["id"] = Json(ch.id);
        cj["name"] = Json(ch.name);
        cj["description"] = Json(ch.description);
        jarr ~= cj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(channels.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto ch = uc.get_(id);
      if (ch.id.isEmpty) {
        writeError(res, 404, "Notification channel not found");
        return;
      }

      auto cj = Json.emptyObject;
      cj["id"] = Json(ch.id);
      cj["name"] = Json(ch.name);
      cj["description"] = Json(ch.description);
      res.writeJsonBody(cj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateNotificationChannelRequest r;
      r.description = j.getString("description");
      r.state = j.getString("state");
      r.emailRecipients = jsonStrArray(j, "emailRecipients");
      r.emailSubjectPrefix = j.getString("emailSubjectPrefix");
      r.webhookUrl = j.getString("webhookUrl");
      r.webhookSecret = j.getString("webhookSecret");
      r.slackWebhookUrl = j.getString("slackWebhookUrl");
      r.slackChannel = j.getString("slackChannel");

      auto result = uc.update(id, r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      uc.remove(id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
