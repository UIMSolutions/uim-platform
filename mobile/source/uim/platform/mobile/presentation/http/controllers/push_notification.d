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

class PushNotificationController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = jsonStr(j, "appId");
      r.title = jsonStr(j, "title");
      r.body_ = jsonStr(j, "body");
      r.payload = jsonStr(j, "payload");
      r.provider = jsonStr(j, "provider");
      r.priority = jsonStr(j, "priority");
      r.targetDevices = jsonStrArray(j, "targetDevices");
      r.targetTopics = jsonStrArray(j, "targetTopics");
      r.scheduledAt = jsonLong(j, "scheduledAt");
      r.expiresAt = jsonLong(j, "expiresAt");
      r.createdBy = jsonStr(j, "createdBy");
      auto result = uc.send(r);
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto results = uc.list(tenantId);
      auto resp = Json.emptyObject;
      auto items = Json.emptyArray;
      foreach (item; results) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(item.id);
        obj["appId"] = Json(item.appId);
        obj["title"] = Json(item.title);
        obj["provider"] = Json(item.provider);
        obj["status"] = Json(item.status);
        items ~= obj;
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
      } else {
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
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
