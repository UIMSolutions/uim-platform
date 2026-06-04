/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.alert_rule;
//
//import uim.platform.logging.application.usecases.manage.alert_rules;
//import uim.platform.logging.application.dto;
//
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class AlertRuleController : ManageController {
  private ManageAlertRulesUseCase usecase;

  this(ManageAlertRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/alert-rules", &handleCreate);
    router.get("/api/v1/alert-rules", &handleList);
    router.get("/api/v1/alert-rules/*", &handleGet);
    router.put("/api/v1/alert-rules/*", &handleUpdate);
    router.delete_("/api/v1/alert-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateAlertRuleRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.query = data.getString("query");
    r.condition = data.getString("condition");
    r.field = data.getString("field");
    r.pattern = data.getString("pattern");
    r.thresholdValue = data.getDouble("thresholdValue");
    r.thresholdOperator = data.getString("thresholdOperator");
    r.evaluationWindowSeconds = data.getInteger("evaluationWindowSeconds");
    r.severity = data.getString("severity");
    r.channelIds = data.getArray("channelIds").map!(v => NotificationChannelId(v.to!string)).array;
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createAlertRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Alert rule created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rules = usecase.listRules(tenantId);

    auto jarr = Json.emptyArray;
    foreach (r; rules) {
      jarr ~= Json.emptyObject
        .set("id", r.id)
        .set("name", r.name)
        .set("description", r.description)
        .set("isEnabled", r.isEnabled);
    }

    auto response = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", rules.length);

    return successResponse("Alert rules retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid alert rule ID", 400);

    auto r = usecase.getRule(tenantId, id);
    auto response = Json.emptyObject
      .set("id", r.id)
      .set("name", r.name)
      .set("description", r.description)
      .set("query", r.query)
      .set("field", r.field)
      .set("pattern", r.pattern)
      .set("isEnabled", r.isEnabled);

    return successResponse("Alert rule retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertRuleId(precheck.id);
    auto data = precheck.data;
    UpdateAlertRuleRequest r;
    r.tenantId = tenantId;
    r.ruleId = id;
    r.description = data.getString("description");
    r.query = data.getString("query");
    r.condition = data.getString("condition");
    r.field = data.getString("field");
    r.pattern = data.getString("pattern");
    r.thresholdValue = data.getDouble("thresholdValue");
    r.thresholdOperator = data.getString("thresholdOperator");
    r.evaluationWindowSeconds = data.getInteger("evaluationWindowSeconds");
    r.severity = data.getString("severity");
    r.isEnabled = data.getBoolean("isEnabled", true);
    r.channelIds = data.getArray("channelIds").map!(v => NotificationChannelId(v.to!string)).array;

    auto result = usecase.updateAlertRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Alert rule updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid alert rule ID", 400);

    auto result = usecase.deleteAlertRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", id);
    return successResponse("Alert rule deleted successfully", "Deleted", 200, resp);
  }
}
