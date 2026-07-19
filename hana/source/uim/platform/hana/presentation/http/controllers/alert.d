/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.alert;
// import uim.platform.hana.application.usecases.manage.alerts;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class AlertController : ManageHttpController {
  private ManageAlertsUseCase usecase;

  this(ManageAlertsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/alerts", &handleList);
    router.get("/api/v1/hana/alerts/*", &handleGet);
    router.post("/api/v1/hana/alerts", &handleCreate);
    router.put("/api/v1/hana/alerts/*", &handleUpdate);
    router.post("/api/v1/hana/alerts/*/acknowledge", &handleAcknowledge);
    router.delete_("/api/v1/hana/alerts/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = AlertId(precheck.data);
    CreateAlertRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.alertId = AlertId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.severity = data.getString("severity");
    r.category = data.getString("category");
    r.metricName = data.getString("metricName");
    r.warningValue = data.getDouble("warningValue");
    r.criticalValue = data.getDouble("criticalValue");
    r.unit = data.getString("unit");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Alert created successfully", 201, resp);
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
        .set("instanceId", a.instanceId)
        .set("name", a.name)
        .set("severity", a.severity.to!string)
        .set("status", a.status.to!string)
        .set("category", a.category.to!string)
        .set("triggeredAt", a.triggeredAt);
    }

    auto resp = Json.emptyObject
      .set("count", alerts.length)
      .set("resources", list);
    return successResponse("Alerts retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertId(precheck.id);
    if (id.isNull) // Defensive check, though super.getHandler should have already validated this
      return errorResponse("Invalid alert ID", 400);

    auto a = usecase.getById(tenantId, id);
    if (a.isNull) // Defensive check, in case the alert was not found
      return errorResponse("Alert not found", 404);

    auto responseData = Json.emptyObject
      .set("id", a.id)
      .set("instanceId", a.instanceId)
      .set("name", a.name)
      .set("description", a.description)
      .set("severity", a.severity.to!string)
      .set("status", a.status.to!string)
      .set("category", a.category.to!string)
      .set("metricName", a.metricName)
      .set("triggeredAt", a.triggeredAt)
      .set("acknowledgedAt", a.acknowledgedAt)
      .set("acknowledgedBy", a.acknowledgedBy)
      .set("resolvedAt", a.resolvedAt)
      .set("createdAt", a.createdAt);

    return successResponse("Alert retrieved successfully", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AlertId(precheck.id);
    if (id.isNull) // Defensive check, though super.updateHandler should have already validated this    
      return errorResponse("Invalid alert ID", 400);

    auto data = precheck.data;
    UpdateAlertRequest r;
    r.tenantId = tenantId;
    r.id = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.severity = data.getString("severity");
    r.warningValue = data.getDouble("warningValue");
    r.criticalValue = data.getDouble("criticalValue");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Alert updated successfully", 200, responseData);
  }

  protected Json acknowledgeHandler(HTTPServerRequest req) {
    auto precheck = super.acknowledgeHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto path = precheck.path;
    auto ackIdx = lastIndexOf(path, "/acknowledge");
    if (ackIdx < 0)
      return errorResponse("Invalid path for acknowledge", 400);

    auto sub = path[0 .. ackIdx];
    auto id = AlertId(extractIdFromPath(sub));
    if (id.isNull)
      return errorResponse("Invalid alert ID", 400);

    auto data = precheck.data;
    AcknowledgeAlertRequest r;
    r.tenantId = tenantId;
    r.alertId = id;
    r.acknowledgedBy = data.getString("acknowledgedBy");

    auto result = usecase.acknowledge(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Alert acknowledged successfully", 200, resp);
  }

  mixin(HandleTemplate!("handleAcknowledge", "acknowledgeHandler"));

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
    return successResponse("Alert deleted successfully", 200, responseData);
  }
}
