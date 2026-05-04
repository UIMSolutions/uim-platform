/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.alert_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.monitoring.application.usecases.manage.alert_rules;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert_rule;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class AlertRuleController : PlatformController {
  private ManageAlertRulesUseCase uc;

  this(ManageAlertRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/alert-rules", &handleCreate);
    router.get("/api/v1/alert-rules", &handleList);
    router.get("/api/v1/alert-rules/*", &handleGetById);
    router.put("/api/v1/alert-rules/*", &handleUpdate);
    router.delete_("/api/v1/alert-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAlertRuleRequest r;
      r.tenantId = req.getTenantId;
      r.resourceId = j.getString("resourceId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.metricName = j.getString("metricName");
      r.metricDefinitionId = j.getString("metricDefinitionId");
      r.operator_ = j.getString("operator");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.evaluationPeriodSeconds = j.getInteger("evaluationPeriodSeconds");
      r.consecutiveBreaches = j.getInteger("consecutiveBreaches");
      r.severity = j.getString("severity");
      r.channelIds = j.getArray("channelIds").map!(c => NotificationChannelId(c.to!string)).array;
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = uc.createRule(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Alert rule created successfully");

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
      auto rules = uc.listRules(tenantId);

      auto arr = rules.map!(r => r.toJson()).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = AlertRuleId(extractIdFromPath(req.requestURI));
      auto r = uc.getRule(id);
      if (r.isNull) {
        writeError(res, 404, "Alert rule not found");
        return;
      }
      res.writeJsonBody(r.toJson(), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = AlertRuleId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      UpdateAlertRuleRequest r;
      r.description = j.getString("description");
      r.warningThreshold = getDouble(j, "warningThreshold");
      r.criticalThreshold = getDouble(j, "criticalThreshold");
      r.evaluationPeriodSeconds = j.getInteger("evaluationPeriodSeconds");
      r.consecutiveBreaches = j.getInteger("consecutiveBreaches");
      r.severity = j.getString("severity");
      r.isEnabled = j.getBoolean("isEnabled", true);
      r.channelIds = j.getArray("channelIds").map!(c => NotificationChannelId(c.to!string)).array;

      auto result = uc.updateRule(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
        .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Alert rule not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = AlertRuleId(extractIdFromPath(req.requestURI));
      auto result = uc.deleteRule(id);
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

}
