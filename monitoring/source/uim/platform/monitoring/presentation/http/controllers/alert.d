/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.alert;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.monitoring.application.usecases.manage.alerts;
import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.alert;
import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.presentation.http.json_utils;

class AlertController {
  private ManageAlertsUseCase uc;

  this(ManageAlertsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/alerts", &handleList);
    router.get("/api/v1/alerts/*", &handleGetById);
    router.post("/api/v1/alerts/acknowledge", &handleAcknowledge);
    router.post("/api/v1/alerts/resolve", &handleResolve);
    router.delete_("/api/v1/alerts/*", &handleDelete);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto state = req.params.get("state", "");
      auto severity = req.params.get("severity", "");

      Alert[] alerts;
      if (state.length > 0)
        alerts = uc.listByState(tenantId, state);
      else if (severity.length > 0)
        alerts = uc.listBySeverity(tenantId, severity);
      else
        alerts = uc.listAlerts(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref a; alerts)
        arr ~= serializeAlert(a);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) alerts.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto a = uc.getAlert(id);
      if (a.id.isEmpty) {
        writeError(res, 404, "Alert not found");
        return;
      }
      res.writeJsonBody(serializeAlert(a), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      AcknowledgeAlertRequest r;
      r.alertId = j.getString("alertId");
      r.tenantId = req.getTenantId;
      r.acknowledgedBy = req.headers.get("X-User-Id", "");

      auto result = uc.acknowledgeAlert(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["state"] = Json("acknowledged");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      ResolveAlertRequest r;
      r.alertId = j.getString("alertId");
      r.tenantId = req.getTenantId;
      r.resolvedBy = req.headers.get("X-User-Id", "");

      auto result = uc.resolveAlert(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["state"] = Json("resolved");
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteAlert(id);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeAlert(const ref Alert a) {
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["ruleId"] = Json(a.ruleId);
    j["resourceId"] = Json(a.resourceId);
    j["ruleName"] = Json(a.ruleName);
    j["metricName"] = Json(a.metricName);
    j["currentValue"] = Json(a.currentValue);
    j["thresholdValue"] = Json(a.thresholdValue);
    j["operator"] = Json(a.operator_.to!string);
    j["severity"] = Json(a.severity.to!string);
    j["state"] = Json(a.state.to!string);
    j["message"] = Json(a.message);
    j["acknowledgedBy"] = Json(a.acknowledgedBy);
    j["resolvedBy"] = Json(a.resolvedBy);
    j["triggeredAt"] = Json(a.triggeredAt);
    j["acknowledgedAt"] = Json(a.acknowledgedAt);
    j["resolvedAt"] = Json(a.resolvedAt);
    return j;
  }
}
