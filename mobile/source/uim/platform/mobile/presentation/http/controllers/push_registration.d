/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.push_registration;

import uim.platform.mobile.application.usecases.manage.push_registrations;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class PushRegistrationController : PlatformController {
  private ManagePushRegistrationsUseCase uc;

  this(ManagePushRegistrationsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/push/registrations", &handleRegister);
    router.get("/api/v1/push/registrations", &handleList);
    router.get("/api/v1/push/registrations/*", &handleGet);
    router.delete_("/api/v1/push/registrations/*", &handleDelete);
  }

  private void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RegisterPushRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.deviceId = j.getString("deviceId");
      r.provider = j.getString("provider");
      r.pushToken = j.getString("pushToken");
      r.topics = getStringArray(j, "topics");
      auto result = uc.register(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Push registration successful");

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
      auto results = uc.list(tenantId);
      auto items = Json.emptyArray;
      foreach (item; results) {
        items ~= Json.emptyObject
          .set("id", item.id)
          .set("appId", item.appId)
          .set("deviceId", item.deviceId)
          .set("provider", item.provider)
          .set("status", item.status);
      }
      auto resp = Json.emptyObject
        .set("items", items);
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
        auto resp = Json.emptyObject
          .set("id", Json(result.data.id))
          .set("tenantId", Json(result.data.tenantId))
          .set("appId", Json(result.data.appId))
          .set("deviceId", Json(result.data.deviceId))
          .set("provider", Json(result.data.provider))
          .set("pushToken", Json(result.data.pushToken))
          .set("topics", toJsonArray(result.data.topics))
          .set("status", Json(result.data.status))
          .set("message", "Push registration retrieved successfully");

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
