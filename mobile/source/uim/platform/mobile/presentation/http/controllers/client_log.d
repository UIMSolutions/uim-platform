/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.client_log;

import uim.platform.mobile.application.usecases.manage.client_logs;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class ClientLogController : PlatformController {
  private ManageClientLogsUseCase uc;

  this(ManageClientLogsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/logs", &handleUpload);
    router.get("/api/v1/logs", &handleList);
    router.get("/api/v1/logs/*", &handleGet);
  }

  private void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UploadClientLogRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.deviceId = j.getString("deviceId");
      r.userId = j.getString("userId");
      r.level = j.getString("level");
      r.source = j.getString("source");
      r.message = j.getString("message");
      r.stackTrace = j.getString("stackTrace");
      r.metadata = j.getString("metadata");
      r.platform = j.getString("platform");
      r.appVersion = j.getString("appVersion");
      r.timestamp = jsonLong(j, "timestamp");
      auto result = uc.upload(r);
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
          .set("level", item.level)
          .set("source", item.source)
          .set("message", item.message);
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
        resp["deviceId"] = Json(result.data.deviceId);
        resp["userId"] = Json(result.data.userId);
        resp["level"] = Json(result.data.level);
        resp["source"] = Json(result.data.source);
        resp["message"] = Json(result.data.message);
        resp["stackTrace"] = Json(result.data.stackTrace);
        resp["metadata"] = Json(result.data.metadata);
        resp["platform"] = Json(result.data.platform);
        resp["appVersion"] = Json(result.data.appVersion);
        resp["timestamp"] = Json(result.data.timestamp);
        res.writeJsonBody(resp, 200);
      } ) {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
