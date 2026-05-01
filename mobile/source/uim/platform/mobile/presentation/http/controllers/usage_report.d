/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.usage_report;

import uim.platform.mobile.application.usecases.manage.usage_reports;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class UsageReportController : PlatformController {
  private ManageUsageReportsUseCase uc;

  this(ManageUsageReportsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usage", &handleReport);
    router.get("/api/v1/usage", &handleList);
    router.get("/api/v1/usage/*", &handleGet);
  }

  private void handleReport(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateUsageReportRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.deviceId = j.getString("deviceId");
      r.userId = j.getString("userId");
      r.metricType = j.getString("metricType");
      r.metricKey = j.getString("metricKey");
      r.metricValue = j.getString("metricValue");
      r.sessionId = j.getString("sessionId");
      r.platform = j.getString("platform");
      r.appVersion = j.getString("appVersion");
      r.timestamp = jsonLong(j, "timestamp");
      auto result = uc.report(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id))
          .set("message", "Usage report created successfully");
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
          .set("metricType", item.metricType)
          .set("metricKey", item.metricKey)
          .set("metricValue", item.metricValue);
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
          .set("id", result.data.id)
          .set("tenantId", result.data.tenantId)
          .set("appId", result.data.appId)
          .set("deviceId", result.data.deviceId)
          .set("userId", result.data.userId)
          .set("metricType", result.data.metricType)
          .set("metricKey", result.data.metricKey)
          .set("metricValue", result.data.metricValue)
          .set("sessionId", result.data.sessionId)
          .set("platform", result.data.platform)
          .set("appVersion", result.data.appVersion)
          .set("timestamp", result.data.timestamp);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
