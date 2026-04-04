/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.usage_report;

import uim.platform.mobile.application.usecases.manage_usage_reports;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class UsageReportController : SAPController {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = jsonStr(j, "appId");
      r.deviceId = jsonStr(j, "deviceId");
      r.userId = jsonStr(j, "userId");
      r.metricType = jsonStr(j, "metricType");
      r.metricKey = jsonStr(j, "metricKey");
      r.metricValue = jsonStr(j, "metricValue");
      r.sessionId = jsonStr(j, "sessionId");
      r.platform = jsonStr(j, "platform");
      r.appVersion = jsonStr(j, "appVersion");
      r.timestamp = jsonLong(j, "timestamp");
      auto result = uc.report(r);
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
        obj["metricType"] = Json(item.metricType);
        obj["metricKey"] = Json(item.metricKey);
        obj["metricValue"] = Json(item.metricValue);
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
        resp["deviceId"] = Json(result.data.deviceId);
        resp["userId"] = Json(result.data.userId);
        resp["metricType"] = Json(result.data.metricType);
        resp["metricKey"] = Json(result.data.metricKey);
        resp["metricValue"] = Json(result.data.metricValue);
        resp["sessionId"] = Json(result.data.sessionId);
        resp["platform"] = Json(result.data.platform);
        resp["appVersion"] = Json(result.data.appVersion);
        resp["timestamp"] = Json(result.data.timestamp);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
