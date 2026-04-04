/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.filter_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.master_data_integration.application.usecases.manage.filter_rules;
import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.filter_rule;
import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.presentation.http.json_utils;

class FilterRuleController : SAPController {
  private ManageFilterRulesUseCase uc;

  this(ManageFilterRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/filter-rules", &handleCreate);
    router.get("/api/v1/filter-rules", &handleList);
    router.get("/api/v1/filter-rules/*", &handleGetById);
    router.put("/api/v1/filter-rules/*", &handleUpdate);
    router.delete_("/api/v1/filter-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateFilterRuleRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.dataModelId = j.getString("dataModelId");
      r.objectType = j.getString("objectType");
      r.logicOperator = j.getString("logicOperator");
      r.createdBy = req.headers.get("X-User-Id", "");
      r.conditions = parseConditions(j);

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto category = req.params.get("category", "");
      auto activeOnly = req.params.get("active", "");

      FilterRule[] rules;
      if (activeOnly == "true")
        rules = uc.listActive(tenantId);
      else if (category.length > 0)
        rules = uc.listByCategory(tenantId, category);
      else
        rules = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; rules)
        arr ~= serializeRule(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long)rules.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getRule(id);
      if (rule.id.length == 0) {
        writeError(res, 404, "Filter rule not found");
        return;
      }
      res.writeJsonBody(serializeRule(rule), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      UpdateFilterRuleRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.logicOperator = j.getString("logicOperator");
      r.isActive = j.getBoolean("isActive", true);
      r.conditions = parseConditions(j);

      auto result = uc.updateRule(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteRule(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private FilterConditionDto[] parseConditions(Json j) {
    FilterConditionDto[] conditions;
    auto condsArr = jsonObjArray(j, "conditions");
    foreach (ref cj; condsArr) {
      FilterConditionDto c;
      c.fieldName = cj.getString("fieldName");
      c.operator = cj.getString("operator");
      c.value = cj.getString("value");
      c.valueList = jsonStrArray(cj, "valueList");
      c.lowerBound = cj.getString("lowerBound");
      c.upperBound = cj.getString("upperBound");
      conditions ~= c;
    }
    return conditions;
  }

  private Json serializeRule(ref FilterRule r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["category"] = Json(r.category.to!string);
    j["dataModelId"] = Json(r.dataModelId);
    j["objectType"] = Json(r.objectType);
    j["logicOperator"] = Json(r.logicOperator);
    j["isActive"] = Json(r.isActive);

    auto condsArr = Json.emptyArray;
    foreach (ref c; r.conditions) {
      auto cj = Json.emptyObject;
      cj["fieldName"] = Json(c.fieldName);
      cj["operator"] = Json(c.operator.to!string);
      cj["value"] = Json(c.value);
      cj["valueList"] = serializeStrArray(c.valueList);
      cj["lowerBound"] = Json(c.lowerBound);
      cj["upperBound"] = Json(c.upperBound);
      condsArr ~= cj;
    }
    j["conditions"] = condsArr;

    j["createdBy"] = Json(r.createdBy);
    j["createdAt"] = Json(r.createdAt);
    j["modifiedAt"] = Json(r.modifiedAt);
    return j;
  }
}
