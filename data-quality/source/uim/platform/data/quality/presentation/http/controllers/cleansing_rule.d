/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.presentation.http.cleansing_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.quality.application.usecases.manage.cleansing_rules;
// import uim.platform.data.quality.application.dto;
// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.cleansing_rule;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class CleansingRuleController : SAPController {
  private ManageCleansingRulesUseCase uc;

  this(ManageCleansingRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cleansing-rules", &handleCreate);
    router.get("/api/v1/cleansing-rules", &handleList);
    router.get("/api/v1/cleansing-rules/*", &handleGetById);
    router.put("/api/v1/cleansing-rules/*", &handleUpdate);
    router.delete_("/api/v1/cleansing-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateCleansingRuleRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.action = parseCleansingAction(j.getString("action"));
      r.findPattern = j.getString("findPattern");
      r.replaceWith = j.getString("replaceWith");
      r.defaultValue = j.getString("defaultValue");
      r.lookupDataset = j.getString("lookupDataset");
      r.lookupField = j.getString("lookupField");
      r.trimWhitespace = j.getBoolean("trimWhitespace");
      r.normalizeCase = j.getBoolean("normalizeCase");
      r.caseMode = j.getString("caseMode");
      r.removeDiacritics = j.getBoolean("removeDiacritics");
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
      TenantId tenantId = req.getTenantId;
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
        writeError(res, 404, "Cleansing rule not found");
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
      auto r = UpdateCleansingRuleRequest();
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.datasetPattern = j.getString("datasetPattern");
      r.fieldName = j.getString("fieldName");
      r.action = parseCleansingAction(j.getString("action"));
      r.status = parseRuleStatus(j.getString("status"));
      r.findPattern = j.getString("findPattern");
      r.replaceWith = j.getString("replaceWith");
      r.defaultValue = j.getString("defaultValue");
      r.lookupDataset = j.getString("lookupDataset");
      r.lookupField = j.getString("lookupField");
      r.trimWhitespace = j.getBoolean("trimWhitespace");
      r.normalizeCase = j.getBoolean("normalizeCase");
      r.caseMode = j.getString("caseMode");
      r.removeDiacritics = j.getBoolean("removeDiacritics");
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
      TenantId tenantId = req.getTenantId;
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

  private static Json serializeRule(ref const CleansingRule r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["datasetPattern"] = Json(r.datasetPattern);
    j["fieldName"] = Json(r.fieldName);
    j["action"] = Json(r.action.to!string);
    j["status"] = Json(r.status.to!string);
    j["findPattern"] = Json(r.findPattern);
    j["replaceWith"] = Json(r.replaceWith);
    j["defaultValue"] = Json(r.defaultValue);
    j["trimWhitespace"] = Json(r.trimWhitespace);
    j["normalizeCase"] = Json(r.normalizeCase);
    j["caseMode"] = Json(r.caseMode);
    j["removeDiacritics"] = Json(r.removeDiacritics);
    j["category"] = Json(r.category);
    j["priority"] = Json(r.priority);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);
    return j;
  }

  private static CleansingAction parseCleansingAction(string s) {
    switch (s) {
    case "trimmed":
      return CleansingAction.trimmed;
    case "normalized":
      return CleansingAction.normalized;
    case "corrected":
      return CleansingAction.corrected;
    case "standardized":
      return CleansingAction.standardized;
    case "enriched":
      return CleansingAction.enriched;
    case "removed":
      return CleansingAction.removed;
    case "defaulted":
      return CleansingAction.defaulted;
    default:
      return CleansingAction.none;
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
