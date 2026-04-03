/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.alert_rule;

import uim.platform.logging.application.use_cases.manage_alert_rules;
import uim.platform.logging.application.dto;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

class AlertRuleController : SAPController {
  private ManageAlertRulesUseCase uc;

  this(ManageAlertRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/alert-rules", &handleCreate);
    router.get("/api/v1/alert-rules", &handleList);
    router.get("/api/v1/alert-rules/*", &handleGet);
    router.put("/api/v1/alert-rules/*", &handleUpdate);
    router.delete_("/api/v1/alert-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateAlertRuleRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.query = jsonStr(j, "query");
      r.condition = jsonStr(j, "condition");
      r.field = jsonStr(j, "field");
      r.pattern = jsonStr(j, "pattern");
      r.thresholdValue = jsonDouble(j, "thresholdValue");
      r.thresholdOperator = jsonStr(j, "thresholdOperator");
      r.evaluationWindowSeconds = jsonInt(j, "evaluationWindowSeconds");
      r.severity = jsonStr(j, "severity");
      r.channelIds = jsonStrArray(j, "channelIds");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = uc.create(r);
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
      auto rules = uc.list(tenantId);

      auto jarr = Json.emptyArray;
      foreach (ref r; rules) {
        auto rj = Json.emptyObject;
        rj["id"] = Json(r.id);
        rj["name"] = Json(r.name);
        rj["description"] = Json(r.description);
        rj["isEnabled"] = Json(r.isEnabled);
        jarr ~= rj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = jarr;
      resp["totalCount"] = Json(cast(long) rules.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto r = uc.get_(id);
      if (r.id.length == 0) {
        writeError(res, 404, "Alert rule not found");
        return;
      }

      auto rj = Json.emptyObject;
      rj["id"] = Json(r.id);
      rj["name"] = Json(r.name);
      rj["description"] = Json(r.description);
      rj["query"] = Json(r.query);
      rj["field"] = Json(r.field);
      rj["pattern"] = Json(r.pattern);
      rj["isEnabled"] = Json(r.isEnabled);
      res.writeJsonBody(rj, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      UpdateAlertRuleRequest r;
      r.description = jsonStr(j, "description");
      r.query = jsonStr(j, "query");
      r.condition = jsonStr(j, "condition");
      r.field = jsonStr(j, "field");
      r.pattern = jsonStr(j, "pattern");
      r.thresholdValue = jsonDouble(j, "thresholdValue");
      r.thresholdOperator = jsonStr(j, "thresholdOperator");
      r.evaluationWindowSeconds = jsonInt(j, "evaluationWindowSeconds");
      r.severity = jsonStr(j, "severity");
      r.isEnabled = jsonBool(j, "isEnabled", true);
      r.channelIds = jsonStrArray(j, "channelIds");

      auto result = uc.update(id, r);
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
