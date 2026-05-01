/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.alert;

// import uim.platform.logging.application.usecases.manage.alerts;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.types;

import uim.platform.logging;

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
    router.get("/api/v1/alerts/*", &handleGet);
    router.post("/api/v1/alerts/acknowledge", &handleAcknowledge);
    router.post("/api/v1/alerts/resolve", &handleResolve);
    router.delete_("/api/v1/alerts/*", &handleDelete);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto alerts = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (a; alerts) {
        jarr ~= Json.emptyObject
          .set("id", a.id)
          .set("ruleId", a.ruleId)
          .set("ruleName", a.ruleName)
          .set("message", a.message)
          .set("matchCount", a.matchCount)
          .set("triggeredAt", a.triggeredAt);
      }

      auto resp = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", Json(alerts.length));
      
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto a = uc.getById(id);
      if (a.isNull) {
        writeError(res, 404, "Alert not found");
        return;
      }

      auto aj = Json.emptyObject
        .set("id", a.id)
        .set("ruleId", a.ruleId)
        .set("ruleName", a.ruleName)
        .set("message", a.message)
        .set("matchCount", a.matchCount)
        .set("sampleLogEntryId", a.sampleLogEntryId)
        .set("triggeredAt", a.triggeredAt)
        .set("acknowledgedAt", a.acknowledgedAt)
        .set("resolvedAt", a.resolvedAt)
        .set("acknowledgedBy", a.acknowledgedBy)
        .set("resolvedBy", a.resolvedBy);

      res.writeJsonBody(aj, 200);
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
      r.acknowledgedBy = j.getString("acknowledgedBy");

      auto result = uc.acknowledge(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
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
      r.resolvedBy = j.getString("resolvedBy");

      auto result = uc.resolve(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id);

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
      uc.removeById(id);

      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
