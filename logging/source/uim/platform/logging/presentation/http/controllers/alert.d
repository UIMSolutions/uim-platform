/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.alert;
// import uim.platform.logging.application.usecases.manage.alerts;
// import uim.platform.logging.application.dto;
// import uim.platform.logging.domain.entities.alert;


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class AlertController : ManageController {
  private ManageAlertsUseCase usecase;

  this(ManageAlertsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/alerts", &handleList);
    router.get("/api/v1/alerts/*", &handleGet);
    router.post("/api/v1/alerts/acknowledge", &handleAcknowledge);
    router.post("/api/v1/alerts/resolve", &handleResolve);
    router.delete_("/api/v1/alerts/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto alerts = usecase.list(tenantId);
    auto list = Json.emptyArray;
    foreach (a; alerts) {
      list ~= Json.emptyObject
        .set("id", a.id)
        .set("ruleId", a.ruleId)
        .set("ruleName", a.ruleName)
        .set("message", a.message)
        .set("matchCount", a.matchCount)
        .set("triggeredAt", a.triggeredAt);
    }

    auto resp = Json.emptyObject
      .set("items", list)
      .set("totalCount", Json(alerts.length));

    return successResponse("Alerts retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid alert ID", 400);

    auto a = usecase.getById(tenantId, id);
    if (a.isNull)
      return errorResponse("Alert not found", 404);

    auto aj = Json.emptyObject
      .set("id", a.id)
      .set("ruleId", a.ruleId)
      .set("ruleName", a.ruleName)
      .set("message", a.message)
      .set("matchCount", a.matchCount)
      .set("sampleLogEntryId", a.sampleLogEntryId)
      .set("triggeredAt", a.triggeredAt)
      .set("acknowledgedAt", a.acknowledgedAt)
      .set("resolvedAt", a.resolvedAt)
      .set("acknowledgedBy", a.acknowledgedBy)
      .set("resolvedBy", a.resolvedBy);

    return successResponse("Alert retrieved successfully", "Retrieved", 200, aj);
  }

  protected Json acknowledgeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    AcknowledgeAlertRequest r;
    r.tenantId = tenantId;
    r.alertId = AlertId(data.getString("alertId"));
    r.acknowledgedBy = data.getString("acknowledgedBy");

    auto result = usecase.acknowledgeAlert(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Alert acknowledged successfully", 200, responseData);
  }

  protected void handleAcknowledge(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = acknowledgeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json resolveHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    ResolveAlertRequest r;
    r.tenantId = tenantId;
    r.alertId = AlertId(data.getString("alertId"));
    r.resolvedBy = data.getString("resolvedBy");

    auto result = usecase.resolveAlert(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Alert resolved successfully", 200, responseData);
  }

  protected void handleResolve(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = resolveHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid alert ID", 400);

    auto result = usecase.deleteAlert(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Alert deleted successfully", 204, responseData);
  }
}
