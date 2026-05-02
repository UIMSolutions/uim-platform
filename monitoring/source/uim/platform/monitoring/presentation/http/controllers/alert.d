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

// import uim.platform.monitoring.application.usecases.manage.alerts;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class AlertController : PlatformController {
  private ManageAlertsUseCase uc;

  this(ManageAlertsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

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

      auto arr = alerts.map!(a => serializeAlert(a)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", alerts.length)
        .set("message", "Alerts retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto a = uc.getAlert(id);
      if (a.isNull) {
        writeError(res, 404, "Alert not found");
        return;
      }
      res.writeJsonBody(serializeAlert(a), 200);
    } catch (Exception e) {
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
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("state", "acknowledged")
          .set("message", "Alert acknowledged successfully");

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
      r.alertId = j.getString("alertId");
      r.tenantId = req.getTenantId;
      r.resolvedBy = req.headers.get("X-User-Id", "");

      auto result = uc.resolveAlert(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("state", "resolved")
          .set("message", "Alert resolved successfully");

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
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteAlert(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeAlert(const ref Alert a) {
    return Json.emptyObject
      .set("id", a.id)
      .set("tenantId", a.tenantId)
      .set("ruleId", a.ruleId.value)
      .set("resourceId", a.resourceId.value)
      .set("ruleName", a.ruleName)
      .set("metricName", a.metricName)
      .set("currentValue", a.currentValue)
      .set("thresholdValue", a.thresholdValue)
      .set("operator", a.operator_.to!string)
      .set("severity", a.severity.to!string)
      .set("state", a.state.to!string)
      .set("message", a.message)
      .set("acknowledgedBy", a.acknowledgedBy)
      .set("resolvedBy", a.resolvedBy)
      .set("triggeredAt", a.triggeredAt)
      .set("acknowledgedAt", a.acknowledgedAt)
      .set("resolvedAt", a.resolvedAt);
  }
}
