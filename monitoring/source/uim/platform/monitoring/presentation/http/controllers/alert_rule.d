/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.alert_rule;

// import uim.platform.monitoring.application.usecases.manage.alert_rules;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert_rule;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;
mixin(ShowModule!());

@safe:
class AlertRuleController : ManageHttpController {
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
    r.resourceId = data.getString("resourceId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.metricName = data.getString("metricName");
    r.metricDefinitionId = data.getString("metricDefinitionId");
    r.operator_ = data.getString("operator");
    r.warningThreshold = data.getDouble("warningThreshold");
    r.criticalThreshold = data.getDouble("criticalThreshold");
    r.evaluationPeriodSeconds = data.getInteger("evaluationPeriodSeconds");
    r.consecutiveBreaches = data.getInteger("consecutiveBreaches");
    r.severity = data.getString("severity");
    r.channelIds = data.getArray("channelIds").map!(c => NotificationChannelId(c.to!string)).array;
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Alert rule created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto rules = usecase.listRules(tenantId);

    auto list = rules.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Alert rule list retrieved successfully", "Retrieved", 200, responseData);
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
    if (r.isNull)
      return errorResponse("Alert rule not found", 404);

    auto responseData = r.toJson();
    return successResponse("Alert rule retrieved successfully", "Retrieved", 200, responseData);
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
    r.alertRuleId = id;
    // r.name = data.getString("name");
    r.description = data.getString("description");
    r.warningThreshold = data.getDouble("warningThreshold");
    r.criticalThreshold = data.getDouble("criticalThreshold");
    r.evaluationPeriodSeconds = data.getInteger("evaluationPeriodSeconds");
    r.consecutiveBreaches = data.getInteger("consecutiveBreaches");
    r.severity = data.getString("severity");
    r.isEnabled = data.getBoolean("isEnabled", true);
    r.channelIds = data.getArray("channelIds").map!(c => NotificationChannelId(c.to!string)).array;

    auto result = usecase.updateRule(r);
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Alert rule updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = AlertRuleId(precheck.id);
  if (id.isNull)
    return errorResponse("Invalid alert rule ID", 400);
    
  auto result = usecase.deleteRule(tenantId, id);
  if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Alert rule deleted successfully", "Deleted", 200, responseData);
}

}
