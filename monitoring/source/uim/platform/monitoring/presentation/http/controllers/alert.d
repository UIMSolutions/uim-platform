/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.alert;

// import uim.platform.monitoring.application.usecases.manage.alerts;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class AlertController : ManageHttpController {
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
    auto state = req.params.get("state", "");
    auto severity = req.params.get("severity", "");

    Alert[] alerts;
    if (state.length > 0)
      alerts = usecase.listByState(tenantId, state.to!AlertState);
    else if (severity.length > 0)
      alerts = usecase.listBySeverity(tenantId, severity.to!AlertSeverity);
    else
      alerts = usecase.listAlerts(tenantId);

    auto arr = alerts.map!(a => a.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", alerts.length);
    return successResponse("Alert list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertId(precheck.id);
    auto a = usecase.getAlert(tenantId, id);
    if (a.isNull)
      return errorResponse("Alert not found", 404);

    return successResponse("Alert retrieved successfully", "Retrieved", 200, a.toJson);
  }

  protected Json acknowledgeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    AcknowledgeAlertRequest r;
    r.alertId = AlertId(data.getString("alertId"));
    r.tenantId = tenantId;
    r.acknowledgedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.acknowledgeAlert(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("state", "acknowledged");

    return successResponse("Alert acknowledged successfully", "Acknowledged", 200, resp);
  }

  mixin(HandleTemplate!("handleAcknowledge", "acknowledgeHandler"));

  protected Json resolveHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    ResolveAlertRequest r;
    r.alertId = AlertId(data.getString("alertId"));
    r.tenantId = tenantId;
    r.resolvedBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.resolveAlert(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto response = Json.emptyObject
      .set("id", result.id)
      .set("state", "resolved");

    return successResponse("Alert resolved successfully", "Resolved", 200, response);
  }

  mixin(HandleTemplate!("handleResolve", "resolveHandler"));

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

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Alert deleted successfully", "Deleted", 200, resp);
  }
}

