/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.check;
// import uim.platform.monitoring.application.usecases.manage.health_checks;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

// mixin(ShowModule!());

@safe:
class CheckController : ManageHttpController {
  private ManageHealthChecksUseCase usecase;

  this(ManageHealthChecksUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/checks", &handleCreate);
    router.get("/api/v1/checks", &handleList);
    router.get("/api/v1/checks/results/*", &handleResults);
    router.get("/api/v1/checks/*", &handleGet);
    router.put("/api/v1/checks/*", &handleUpdate);
    router.delete_("/api/v1/checks/*", &handleDelete);
    router.post("/api/v1/checks/results", &handleRecordResult);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateHealthCheckRequest r;
    r.tenantId = tenantId;
    r.resourceId = data.getString("resourceId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.checkType = data.getString("checkType");
    r.intervalSeconds = data.getInteger("intervalSeconds");
    r.url = data.getString("url");
    r.expectedStatus = data.getString("expectedStatus");
    r.mbeanName = data.getString("mbeanName");
    r.mbeanAttribute = data.getString("mbeanAttribute");
    r.customUrl = data.getString("customUrl");
    r.expectedResponseContains = data.getString("expectedResponseContains");
    r.warningThreshold = data.getDouble("warningThreshold");
    r.criticalThreshold = data.getDouble("criticalThreshold");
    r.thresholdOperator = data.getString("thresholdOperator");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createCheck(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Health check created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto checks = usecase.listChecks(tenantId);
    auto list = checks.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Health check list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = HealthCheckId(precheck.id);

    auto c = usecase.getCheck(tenantId, id);
    if (c.isNull)
      return errorResponse("Health check not found", 404);

    auto responseData = c.toJson();
    return successResponse("Health check retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = HealthCheckId(precheck.id);

    auto data = precheck.data;
    UpdateHealthCheckRequest r;
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.isEnabled = data.getBoolean("isEnabled", true);
    r.intervalSeconds = data.getInteger("intervalSeconds");
    r.url = data.getString("url");
    r.expectedStatus = data.getString("expectedStatus");
    r.warningThreshold = data.getDouble("warningThreshold");
    r.criticalThreshold = data.getDouble("criticalThreshold");
    r.thresholdOperator = data.getString("thresholdOperator");

    auto result = usecase.updateCheck(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Health check updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = HealthCheckId(precheck.id);

    auto result = usecase.deleteCheck(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Health check deleted successfully", "Deleted", 200, responseData);
  }

  protected Json recordResultHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RecordCheckResultRequest r;
    r.tenantId = tenantId;
    r.checkId = HealthCheckId(data.getString("checkId"));
    r.resourceId = MonitoredResourceId(data.getString("resourceId"));
    r.status = data.getString("status");
    r.value_ = data.getDouble("value");
    r.message = data.getString("message");
    r.responseTimeMs = data.getInteger("responseTimeMs");
    r.httpStatusCode = data.getInteger("httpStatusCode");

    auto result = usecase.recordResult(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Health check result recorded successfully", "Recorded", 201, resp);
  }

  protected void handleRecordResult(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = recordResultHandler(req);
      res.writeJsonBody(response.data, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json resultsHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

      auto tenantId = precheck.tenantId;
      auto checkId = HealthCheckId(precheck.id);
      auto results = usecase.getResults(tenantId, checkId);

      auto arr = results.map!(result => result.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(results.length));

        return successResponse("Health check results retrieved successfully", "Retrieved", 200, resp);
  } 

  protected void handleResults(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = resultsHandler(req);
      res.writeJsonBody(response.data, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
