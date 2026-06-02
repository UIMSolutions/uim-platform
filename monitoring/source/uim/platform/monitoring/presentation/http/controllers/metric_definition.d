/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.metric_definition;

// import uim.platform.monitoring.application.usecases.manage.metrics;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.metric_definition;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MetricDefinitionController : ManageController {
  private ManageMetricsUseCase usecase;

  this(ManageMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/metric-definitions", &handleCreate);
    router.get("/api/v1/metric-definitions", &handleList);
    router.get("/api/v1/metric-definitions/*", &handleGet);
    router.put("/api/v1/metric-definitions/*", &handleUpdate);
    router.delete_("/api/v1/metric-definitions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    CreateMetricDefinitionRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.displayName = data.getString("displayName");
    r.description = data.getString("description");
    r.category = data.getString("category");
    r.unit = data.getString("unit");
    r.aggregation = data.getString("aggregation");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createDefinition(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Metric definition created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto defs = usecase.listDefinitions(tenantId);

    auto list = defs.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", defs.length)
      .set("resources", list);
    return successResponse("Metric definition list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MetricDefinitionId(precheck.id);

    auto d = usecase.getDefinition(tenantId, id);
    if (d.isNull)
      return errorResponse("Metric definition not found", 404);

    auto responseData = d.toJson();
    return successResponse("Metric definition retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MetricDefinitionId(precheck.id);

    auto data = precheck.data;
    UpdateMetricDefinitionRequest request;
    request.tenantId = tenantId;
    request.id = id;
    request.displayName = data.getString("displayName");
    request.description = data.getString("description");
    request.aggregation = data.getString("aggregation");
    request.isEnabled = data.getBoolean("isEnabled", true);

    auto result = usecase.updateDefinition(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Metric definition updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MetricDefinitionId(precheck.id);

    auto result = usecase.deleteMetricDefinition(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Metric definition deleted successfully", "Deleted", 200, responseData);
  }

}
