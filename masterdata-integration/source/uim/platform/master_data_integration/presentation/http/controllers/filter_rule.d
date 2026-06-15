/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.presentation.http.controllers.filter_rule;

// import uim.platform.master_data_integration.application.usecases.manage.filter_rules;

// import uim.platform.master_data_integration.domain.entities.filter_rule;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
class FilterRuleController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateFilterRuleRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.modelId = DataModelId(data.getString("dataModelId"));
    r.objectType = data.getString("objectType");
    r.logicOperator = data.getString("logicOperator");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.conditions = parseConditions(data);

    auto result = usecase.createRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Filter rule created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto category = req.params.get("category", "");
    auto activeOnly = req.params.get("active", "");

    FilterRule[] rules;
    if (activeOnly == "true")
      rules = usecase.listRulesActive(tenantId);
    else if (category.length > 0)
      rules = usecase.listRulesByCategory(tenantId, category);
    else
      rules = usecase.listRules(tenantId);

    auto arr = rules.map!(r => r.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", rules.length)
      .set("message", "Filter rules retrieved successfully");

    return successResponse("Filter rules retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FilterRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid filter rule ID", 400);

    auto rule = usecase.getRule(tenantId, id);
    if (rule.isNull)
      return errorResponse("Filter rule not found", 404);

    auto response = rule.toJson();
    return successResponse("Filter rule retrieved successfully", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FilterRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid filter rule ID", 400);

    auto data = precheck.data;
    UpdateFilterRuleRequest r;
    r.tenantId = tenantId;
    r.ruleId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.logicOperator = data.getString("logicOperator");
    r.isActive = data.getBoolean("isActive", true);
    r.conditions = parseConditions(data);

    auto result = usecase.updateRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);
    return successResponse("Filter rule updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = FilterRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid filter rule ID", 400);

    auto result = usecase.deleteRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);
    return successResponse("Filter rule deleted successfully", 200, resp);
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
}
