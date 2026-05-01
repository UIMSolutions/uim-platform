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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Client log uploaded successfully");

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
          .set("level", item.level)
          .set("source", item.source)
          .set("message", item.message);
      }

      auto resp = Json.emptyObject
        .set("items", items)
        .set("totalCount", results.length)
        .set("message", "Client logs retrieved successfully");
        
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
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("deviceId", result.data.deviceId)
          .set("userId", result.data.userId)
          .set("level", result.data.level)
          .set("source", result.data.source)
          .set("message", result.data.message)
          .set("stackTrace", result.data.stackTrace)
          .set("metadata", result.data.metadata)
          .set("platform", result.data.platform)
          .set("appVersion", result.data.appVersion)
          .set("timestamp", result.data.timestamp)
          .set("message", "Client log retrieved successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
