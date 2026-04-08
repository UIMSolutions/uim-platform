/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data - quality.presentation.http.controllers.validation_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.quality.application.usecases.manage.validation_rules;
import uim.platform.data.quality.application.dto;
import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;

class ValidationRuleController : SAPController {
  private ManageValidationRulesUseCase uc;

  this(ManageValidationRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/validation-rules", &handleCreate);
    router.get("/api/v1/validation-rules", &handleList);
    router.get("/api/v1/validation-rules/*", &handleGetById);
    router.put("/api/v1/validation-rules/*", &handleUpdate);
    router.delete_("/api/v1/validation-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateValidationRuleRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.ruleType = parseRuleType(j.getString("ruleType"));
      r.severity = parseSeverity(j.getString("severity"));
      r.pattern = j.getString("pattern");
      r.minValue = j.getString("minValue");
      r.maxValue = j.getString("maxValue");
      r.allowedValues = jsonStrArray(j, "allowedValues");
      r.expression = j.getString("expression");
      r.referenceDataset = j.getString("referenceDataset");
      r.crossFieldName = j.getString("crossFieldName");
      r.category = j.getString("category");
      r.priority = j.getInteger("priority");

      auto result = uc.create(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rules = uc.listByTenant(tenantId);
      auto arr = Json.emptyArray;
      foreach (ref r; rules)
        arr ~= serializeRule(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) rules.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getById(id);
      if (rule is null) {
        writeError(res, 404, "Validation rule not found");
        return;
      }
      res.writeJsonBody(serializeRule(*rule), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = UpdateValidationRuleRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.ruleType = parseRuleType(j.getString("ruleType"));
      r.severity = parseSeverity(j.getString("severity"));
      r.status = parseRuleStatus(j.getString("status"));
      r.pattern = j.getString("pattern");
      r.minValue = j.getString("minValue");
      r.maxValue = j.getString("maxValue");
      r.allowedValues = jsonStrArray(j, "allowedValues");
      r.expression = j.getString("expression");
      r.referenceDataset = j.getString("referenceDataset");
      r.crossFieldName = j.getString("crossFieldName");
      r.category = j.getString("category");
      r.priority = j.getInteger("priority");

      auto result = uc.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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
      auto tenantId = req.getTenantId;
      auto result = uc.remove(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRule(ref const ValidationRule r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["datasetPattern"] = Json(r.datasetPattern);
    j["fieldName"] = Json(r.fieldName);
    j["ruleType"] = Json(r.ruleType.to!string);
    j["severity"] = Json(r.severity.to!string);
    j["status"] = Json(r.status.to!string);
    j["pattern"] = Json(r.pattern);
    j["minValue"] = Json(r.minValue);
    j["maxValue"] = Json(r.maxValue);
    j["category"] = Json(r.category);
    j["priority"] = Json(r.priority);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);

    if (r.allowedValues.length > 0) {
      auto arr = Json.emptyArray;
      foreach (v; r.allowedValues)
        arr ~= Json(v);
      j["allowedValues"] = arr;
    }

    return j;
  }

  private static RuleType parseRuleType(string s) {
    switch (s) {
    case "required":
      return RuleType.required;
    case "format":
      return RuleType.format_;
    case "range":
      return RuleType.range;
    case "enumeration":
      return RuleType.enumeration;
    case "length":
      return RuleType.length;
    case "crossField":
      return RuleType.crossField;
    case "custom":
      return RuleType.custom;
    case "referenceData":
      return RuleType.referenceData;
    default:
      return RuleType.required;
    }
  }

  private static RuleSeverity parseSeverity(string s) {
    switch (s) {
    case "warning":
      return RuleSeverity.warning;
    case "error":
      return RuleSeverity.error;
    case "critical":
      return RuleSeverity.critical;
    default:
      return RuleSeverity.info;
    }
  }

  private static RuleStatus parseRuleStatus(string s) {
    switch (s) {
    case "active":
      return RuleStatus.active;
    case "inactive":
      return RuleStatus.inactive;
    default:
      return RuleStatus.draft;
    }
  }
}
