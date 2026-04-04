/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.alert;

import uim.platform.hana.application.usecases.manage.alerts;
import uim.platform.hana.application.dto;
import uim.platform.hana.presentation.http.json_utils;

import uim.platform.hana;

class AlertController : SAPController {
  private ManageAlertsUseCase uc;

  this(ManageAlertsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/alerts", &handleList);
    router.get("/api/v1/hana/alerts/*", &handleGet);
    router.post("/api/v1/hana/alerts", &handleCreate);
    router.put("/api/v1/hana/alerts/*", &handleUpdate);
    router.post("/api/v1/hana/alerts/*/acknowledge", &handleAcknowledge);
    router.delete_("/api/v1/hana/alerts/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAlertRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.instanceId = jsonStr(j, "instanceId");
      r.id = jsonStr(j, "id");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.severity = jsonStr(j, "severity");
      r.category = jsonStr(j, "category");
      r.metricName = jsonStr(j, "metricName");
      r.warningValue = jsonDouble(j, "warningValue");
      r.criticalValue = jsonDouble(j, "criticalValue");
      r.unit = jsonStr(j, "unit");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Alert created");
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
      auto alerts = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref a; alerts) {
        auto aj = Json.emptyObject;
        aj["id"] = Json(a.id);
        aj["instanceId"] = Json(a.instanceId);
        aj["name"] = Json(a.name);
        aj["severity"] = Json(a.severity.to!string);
        aj["status"] = Json(a.status.to!string);
        aj["category"] = Json(a.category.to!string);
        aj["triggeredAt"] = Json(a.triggeredAt);
        jarr ~= aj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) alerts.length);
      resp["resources"] = jarr;
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

      auto resp = Json.emptyObject;
      resp["id"] = Json(a.id);
      resp["instanceId"] = Json(a.instanceId);
      resp["name"] = Json(a.name);
      resp["description"] = Json(a.description);
      resp["severity"] = Json(a.severity.to!string);
      resp["status"] = Json(a.status.to!string);
      resp["category"] = Json(a.category.to!string);
      resp["metricName"] = Json(a.metricName);
      resp["triggeredAt"] = Json(a.triggeredAt);
      resp["acknowledgedAt"] = Json(a.acknowledgedAt);
      resp["acknowledgedBy"] = Json(a.acknowledgedBy);
      resp["resolvedAt"] = Json(a.resolvedAt);
      resp["createdAt"] = Json(a.createdAt);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto j = req.json;
      UpdateAlertRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = extractIdFromPath(req.requestURI.to!string);
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.severity = jsonStr(j, "severity");
      r.warningValue = jsonDouble(j, "warningValue");
      r.criticalValue = jsonDouble(j, "criticalValue");

      auto result = uc.update(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Alert updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;
      import std.string : lastIndexOf;

      auto path = req.requestURI.to!string;
      auto ackIdx = lastIndexOf(path, "/acknowledge");
      if (ackIdx < 0) {
        writeError(res, 400, "Invalid path");
        return;
      }
      auto sub = path[0 .. ackIdx];
      auto id = extractIdFromPath(sub);

      auto j = req.json;
      AcknowledgeAlertRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.id = id;
      r.acknowledgedBy = jsonStr(j, "acknowledgedBy");

      auto result = uc.acknowledge(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Alert acknowledged");
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
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto result = uc.remove(id);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
