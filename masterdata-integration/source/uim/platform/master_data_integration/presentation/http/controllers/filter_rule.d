/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.filter_rule;

// import uim.platform.master_data_integration.application.usecases.manage.filter_rules;
// import uim.platform.master_data_integration.application.dto;
// import uim.platform.master_data_integration.domain.entities.filter_rule;
// import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
class FilterRuleController : ManageController {
  private ManageFilterRulesUseCase usecase;

  this(ManageFilterRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/filter-rules", &handleCreate);
    router.get("/api/v1/filter-rules", &handleList);
    router.get("/api/v1/filter-rules/*", &handleGet);
    router.put("/api/v1/filter-rules/*", &handleUpdate);
    router.delete_("/api/v1/filter-rules/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreateFilterRuleRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.category = j.getString("category");
      r.dataModelId = j.getString("dataModelId");
      r.objectType = j.getString("objectType");
      r.logicOperator = j.getString("logicOperator");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.conditions = parseConditions(j);

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Filter rule created successfully");
          
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto category = req.params.get("category", "");
      auto activeOnly = req.params.get("active", "");

      FilterRule[] rules;
      if (activeOnly == "true")
        rules = usecase.listActive(tenantId);
      else if (category.length > 0)
        rules = usecase.listByCategory(tenantId, category);
      else
        rules = usecase.listByTenant(tenantId);

      auto arr = rules.map!(r => r.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", rules.length)
        .set("message", "Filter rules retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto rule = usecase.getRule(id);
      if (rule.isNull) {
        writeError(res, 404, "Filter rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto j = req.json;
      UpdateFilterRuleRequest r;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.logicOperator = j.getString("logicOperator");
      r.isActive = j.getBoolean("isActive", true);
      r.conditions = parseConditions(j);

      auto result = usecase.updateRule(id, r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto result = usecase.deleteRule(id);
      if (result.success)
        res.writeBody("", 204);
      else
        writeError(res, 404, result.message);
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
      c.valueList = getStrings(cj, "valueList");
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
