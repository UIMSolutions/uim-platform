/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.metric;

// import uim.platform.monitoring.application.usecases.manage.metrics;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.metric;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;
mixin(ShowModule!());

@safe:
class MetricController : ManageHttpController {
  private ManageMetricsUseCase usecase;

  this(ManageMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/metrics", &handlePush);
    router.post("/api/v1/metrics/batch", &handleBatchPush);
    router.get("/api/v1/metrics", &handleQuery);
    router.get("/api/v1/metrics/summary", &handleSummary);
  }

  protected Json pushHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    PushMetricRequest r;
    r.tenantId = tenantId;
    r.resourceId = data.getString("resourceId");
    r.name = data.getString("name");
    r.value_ = data.getDouble("value");
    r.unit = data.getString("unit");
    r.category = data.getString("category");

    auto result = usecase.pushMetric(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Metric pushed successfully", "Created", 201, responseData);
  }

  mixin(HandleTemplate!("handlePush", "pushHandler"));

  protected Json batchPushHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    PushMetricBatchRequest batchReq;
    batchReq.tenantId = tenantId;

    auto data = precheck.data;
    foreach (mj; data.getArray("metrics")) {
      if (!mj.isObject)
        continue;

      PushMetricRequest r;
      r.tenantId = tenantId;
      r.resourceId = mj.getString("resourceId");
      r.name = mj.getString("name");
      r.value_ = getDouble(mj, "value");
      r.unit = mj.getString("unit");
      r.category = mj.getString("category");
      batchReq.metrics ~= r;
    }

    auto result = usecase.pushMetricBatch(batchReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("accepted", batchReq.metrics.length);
    return successResponse("Metrics batch pushed successfully", "Created", 201, responseData);
  }

  mixin(HandleTemplate!("handleBatchPush", "batchPushHandler"));

  protected Json queryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MonitoredResourceId(req.params.get("resourceId", ""));
    if (id.isEmpty)
      return errorResponse("Missing required parameter: resourceId", 400);

    auto metricName = req.params.get("name", "");

    QueryMetricsRequest qr;
    qr.tenantId = tenantId;
    qr.resourceId = id;
    qr.metricName = metricName;
    auto metrics = usecase.queryMetrics(qr);
    auto arr = metrics.map!(m => m.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(metrics.length));
    return successResponse("Metrics retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleQuery", "queryHandler"));

  protected Json summaryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto resourceId = MonitoredResourceId(req.params.get("resourceId", ""));
    auto metricName = req.params.get("name", "");

    auto now = Clock.currTime().toUnixTime();
    auto windowStart = now - 3600; // Default 1 hour window

    auto summary = usecase.computeSummary(tenantId, resourceId, metricName, windowStart, now);

    auto responseData = Json.emptyObject
      .set("name", summary.name)
      .set("resourceId", summary.resourceId)
      .set("minValue", summary.minValue)
      .set("maxValue", summary.maxValue)
      .set("avgValue", summary.avgValue)
      .set("sumValue", summary.sumValue)
      .set("dataPointCount", summary.dataPointCount)
      .set("windowStartTime", summary.windowStartTime)
      .set("windowEndTime", summary.windowEndTime);
    return successResponse("Metric summary retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleSummary", "summaryHandler"));

}
