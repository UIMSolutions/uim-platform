/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.alert;

import uim.platform.logging.application.use_cases.manage_alerts;
import uim.platform.logging.application.dto;
import uim.platform.logging.domain.entities.alert;
import uim.platform.logging.domain.types;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class AlertController : SAPController {
  private ManageAlertsUseCase uc;

  this(ManageAlertsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/alerts", &handleList);
    router.get("/api/v1/alerts/*", &handleGet);
    router.post("/api/v1/alerts/acknowledge", &handleAcknowledge);
    router.post("/api/v1/alerts/resolve", &handleResolve);
    router.delete_("/api/v1/alerts/*", &handleDelete);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto alerts = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref a; alerts) {
        auto aj = Json.emptyObject;
        aj["id"] = Json(a.id);
        aj["ruleId"] = Json(a.ruleId);
        aj["ruleName"] = Json(a.ruleName);
        aj["message"] = Json(a.message);
        aj["matchCount"] = Json(a.matchCount);
        aj["triggeredAt"] = Json(a.triggeredAt);
        jarr ~= aj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) alerts.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto a = uc.get_(id);
      if (a.id.length == 0) {
        writeError(res, 404, "Alert not found");
        return;
      }

      auto aj = Json.emptyObject;
      aj["id"] = Json(a.id);
      aj["ruleId"] = Json(a.ruleId);
      aj["ruleName"] = Json(a.ruleName);
      aj["message"] = Json(a.message);
      aj["matchCount"] = Json(a.matchCount);
      aj["sampleLogEntryId"] = Json(a.sampleLogEntryId);
      aj["triggeredAt"] = Json(a.triggeredAt);
      aj["acknowledgedAt"] = Json(a.acknowledgedAt);
      aj["resolvedAt"] = Json(a.resolvedAt);
      aj["acknowledgedBy"] = Json(a.acknowledgedBy);
      aj["resolvedBy"] = Json(a.resolvedBy);
      res.writeJsonBody(aj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      AcknowledgeAlertRequest r;
      r.alertId = jsonStr(j, "alertId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.acknowledgedBy = jsonStr(j, "acknowledgedBy");

      auto result = uc.acknowledge(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      ResolveAlertRequest r;
      r.alertId = jsonStr(j, "alertId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.resolvedBy = jsonStr(j, "resolvedBy");

      auto result = uc.resolve(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else {
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
