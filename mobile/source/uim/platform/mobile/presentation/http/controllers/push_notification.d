/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.push_notification;

import uim.platform.mobile.application.usecases.manage.push_notifications;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class PushNotificationController : PlatformController {
  private ManagePushNotificationsUseCase uc;

  this(ManagePushNotificationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/push/notifications", &handleSend);
    router.get("/api/v1/push/notifications", &handleList);
    router.get("/api/v1/push/notifications/*", &handleGet);
    router.delete_("/api/v1/push/notifications/*", &handleDelete);
  }

  private void handleSend(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      SendPushNotificationRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.title = j.getString("title");
      r.body_ = j.getString("body");
      r.payload = j.getString("payload");
      r.provider = j.getString("provider");
      r.priority = j.getString("priority");
      r.targetDevices = jsonStrArray(j, "targetDevices");
      r.targetTopics = jsonStrArray(j, "targetTopics");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = j.getString("createdBy");
      auto result = uc.send(r);
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
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("title", item.title)
        .set("provider", item.provider)
        .set("status", item.status);
      }
      resp["items"] = items;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.get(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.data.id);
        resp["tenantId"] = Json(result.data.tenantId);
        resp["appId"] = Json(result.data.appId);
        resp["title"] = Json(result.data.title);
        resp["body"] = Json(result.data.body_);
        resp["payload"] = Json(result.data.payload);
        resp["provider"] = Json(result.data.provider);
        resp["priority"] = Json(result.data.priority);
        resp["targetDevices"] = toJsonArray(result.data.targetDevices);
        resp["targetTopics"] = toJsonArray(result.data.targetTopics);
        resp["scheduledAt"] = Json(result.data.scheduledAt);
        resp["expiresAt"] = Json(result.data.expiresAt);
        resp["status"] = Json(result.data.status);
        resp["createdBy"] = Json(result.data.createdBy);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeBody("", 204);
      } ) {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
