/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.cleansing_rule;

// import uim.platform.data_quality.application.usecases.manage.cleansing_rules;


// import uim.platform.data_quality.domain.entities.cleansing_rule;
import uim.platform.service;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
class CleansingRuleController : ManageHttpController {
  private ManageCleansingRulesUseCase usecase;

  this(ManageCleansingRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cleansing-rules", &handleCreate);
    router.get("/api/v1/cleansing-rules", &handleList);
    router.get("/api/v1/cleansing-rules/*", &handleGet);
    router.put("/api/v1/cleansing-rules/*", &handleUpdate);
    router.delete_("/api/v1/cleansing-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateCleansingRuleRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.datasetPattern = data.getString("datasetPattern");
    r.fieldName = data.getString("fieldName");
    r.action = data.getString("action");
    r.findPattern = data.getString("findPattern");
    r.replaceWith = data.getString("replaceWith");
    r.defaultValue = data.getString("defaultValue");
    r.lookupDataset = data.getString("lookupDataset");
    r.lookupField = data.getString("lookupField");
    r.trimWhitespace = data.getBoolean("trimWhitespace");
    r.normalizeCase = data.getBoolean("normalizeCase");
    r.caseMode = data.getString("caseMode");
    r.removeDiacritics = data.getBoolean("removeDiacritics");
    r.category = data.getString("category");
    r.priority = data.getInteger("priority");

    auto result = usecase.createCleansingRule(r);
    if (result.isNull)
      return errorResponse("Cleansing rule not found", 404);

    auto responseData = result.toJson();
    return successResponse("Cleansing rule created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rules = usecase.listCleansingRules(tenantId);
    auto list = rules.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CleansingRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid cleansing rule ID", 400);

    auto rule = usecase.getCleansingRule(tenantId, id);
    if (rule.isNull)
      return errorResponse("Cleansing rule not found", 404);

    auto responseData = rule.toJson();
    return successResponse("Cleansing rule retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CleansingRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid cleansing rule ID", 400);

    auto data = precheck.data;
    auto r = UpdateCleansingRuleRequest();
    r.ruleId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.datasetPattern = data.getString("datasetPattern");
    r.fieldName = data.getString("fieldName");
    r.action = data.getString("action");
    r.status = data.getString("status");
    r.findPattern = data.getString("findPattern");
    r.replaceWith = data.getString("replaceWith");
    r.defaultValue = data.getString("defaultValue");
    r.lookupDataset = data.getString("lookupDataset");
    r.lookupField = data.getString("lookupField");
    r.trimWhitespace = data.getBoolean("trimWhitespace");
    r.normalizeCase = data.getBoolean("normalizeCase");
    r.caseMode = data.getString("caseMode");
    r.removeDiacritics = data.getBoolean("removeDiacritics");
    r.category = data.getString("category");
    r.priority = data.getInteger("priority");

    auto result = usecase.update(r);
    if (result.isNull)
      return errorResponse("Cleansing rule not found", 404);

    auto responseData = result.toJson();
    return successResponse("Cleansing rule updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = CleansingRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid cleansing rule ID", 400);

    auto result = usecase.deleteCleansingRule(tenantId, id);
    if (result.isNull)
      return errorResponse("Cleansing rule not found", 404);

    auto responseData = result.toJson();
    return successResponse("Cleansing rule deleted successfully", 200, responseData);
  }

}
