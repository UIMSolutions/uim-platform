/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.presentation.http.controllers.automation_rule;
// import uim.platform.situation_automation.application.usecases.manage.automation_rules;
// import uim.platform.situation_automation.application.dto;
// 
import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:

class AutomationRuleController : ManageHttpController {
  private ManageAutomationRulesUseCase usecase;

  this(ManageAutomationRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/situation-automation/rules", &handleList);
    router.get("/api/v1/situation-automation/rules/*", &handleGet);
    router.post("/api/v1/situation-automation/rules", &handleCreate);
    router.put("/api/v1/situation-automation/rules/*", &handleUpdate);
    router.delete_("/api/v1/situation-automation/rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAutomationRuleRequest r;
    r.tenantId = tenantId;
    r.situationTemplateId = SituationTemplateId(data.getString("templateId"));
    r.automationRuleId = AutomationRuleId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.priority = data.getString("priority");
    r.executionOrder = data.getInteger("executionOrder");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createAutomationRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Automation rule created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rules = usecase.listAutomationRules(tenantId);

    auto jarr = Json.emptyArray;
    foreach (r; rules) {
      jarr ~= Json.emptyObject
        .set("id", r.id.value)
        .set("name", r.name)
        .set("situationTemplateId", r.situationTemplateId.value)
        .set("status", r.status.to!string)
        .set("priority", r.priority.to!string)
        .set("enabled", r.enabled)
        .set("executionOrder", r.executionOrder)
        .set("triggerCount", r.triggerCount)
        .set("successCount", r.successCount)
        .set("failureCount", r.failureCount)
        .set("createdAt", r.createdAt);
    }

    auto resp = Json.emptyObject
      .set("count", Json(rules.length))
      .set("resources", jarr);

    return successResponse("Automation rules retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AutomationRuleId(precheck.id);
    auto r = usecase.getAutomationRule(tenantId, id);
    if (r.isNull)
      return errorResponse("Automation rule not found", 404);

    auto resp = Json.emptyObject
      .set("id", r.id.value)
      .set("name", r.name)
      .set("description", r.description)
      .set("situationTemplateId", r.situationTemplateId.value)
      .set("status", r.status.to!string)
      .set("priority", r.priority.to!string)
      .set("enabled", r.enabled)
      .set("executionOrder", r.executionOrder)
      .set("createdBy", r.createdBy)
      .set("updatedBy", r.updatedBy)
      .set("createdAt", r.createdAt)
      .set("updatedAt", r.updatedAt)
      .set("lastTriggeredAt", r.lastTriggeredAt)
      .set("triggerCount", r.triggerCount)
      .set("successCount", r.successCount)
      .set("failureCount", r.failureCount);

    return successResponse("Automation rule retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateAutomationRuleRequest r;
    r.tenantId = tenantId;
    r.automationRuleId = AutomationRuleId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.priority = data.getString("priority");
    r.executionOrder = data.getInteger("executionOrder");
    r.enabled = data.getBoolean("enabled", true);
    r.updatedBy = UserId(data.getString("updatedBy"));

    auto result = usecase.updateAutomationRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Automation rule updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AutomationRuleId(precheck.id);
    auto result = usecase.deleteAutomationRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Automation rule deleted successfully", 200, responseData);
  }
}
