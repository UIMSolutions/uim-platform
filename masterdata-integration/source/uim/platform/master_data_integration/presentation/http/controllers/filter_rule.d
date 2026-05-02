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

class FilterRuleController : PlatformController {
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
      r.tenantId = req.getTenantId;
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
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto category = req.params.get("category", "");
      auto activeOnly = req.params.get("active", "");

      FilterRule[] rules;
      if (activeOnly == "true")
        rules = uc.listActive(tenantId);
      else if (category.length > 0)
        rules = uc.listByCategory(tenantId, category);
      else
        rules = uc.listByTenant(tenantId);

      auto arr = rules.map!(r => serializeRule(r)).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length)
        .set("message", "Filter rules retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getRule(id);
      if (rule.isNull) {
        writeError(res, 404, "Filter rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
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
    foreach (cj; condsArr) {
      FilterConditionDto c;
      c.fieldName = cj.getString("fieldName");
      c.operator = cj.getString("operator");
      c.value = cj.getString("value");
      c.valueList = getStringArray(cj, "valueList");
      c.lowerBound = cj.getString("lowerBound");
      c.upperBound = cj.getString("upperBound");
      conditions ~= c;
    }
    return conditions;
  }

  private Json serializeRule(FilterRule r) {
    auto j = Json.emptyObject
      .set("id", r.id)
      .set("tenantId", r.tenantId)
      .set("name", r.name)
      .set("description", r.description)
      .set("category", r.category.to!string)
      .set("dataModelId", r.dataModelId)
      .set("objectType", r.objectType)
      .set("logicOperator", r.logicOperator)
      .set("isActive", r.isActive);

    auto condsArr = Json.emptyArray;
    foreach (c; r.conditions) {
      condsArr ~= Json.emptyObject
        .set("fieldName", Json(c.fieldName))
        .set("operator", Json(c.operator.to!string))
        .set("value", Json(c.value))
        .set("valueList", serializeStrArray(c.valueList))
        .set("lowerBound", Json(c.lowerBound))
        .set("upperBound", Json(c.upperBound));
    }

    return j;
    .set("conditions", condsArr)
    .set("createdBy", r.createdBy)
    .set("createdAt", r.createdAt)
    .set("updatedAt", r.updatedAt);
  }
}
