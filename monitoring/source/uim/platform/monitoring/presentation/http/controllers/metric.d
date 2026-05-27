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
class MetricController : ManageController {
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

  protected void handlePush(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      PushMetricRequest r;
      r.tenantId = tenantId;
      r.resourceId = data.getString("resourceId");
      r.name = data.getString("name");
      r.value_ = getDouble(j, "value");
      r.unit = data.getString("unit");
      r.category = data.getString("category");

      auto result = usecase.pushMetric(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleBatchPush(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      PushMetricBatchRequest batchReq;
      batchReq.tenantId = tenantId;

      foreach (mj; j.getArray("metrics")) {
        if (!mj.isObject)
          continue;

        PushMetricRequest r;
        r.tenantId = tenantId;
        r.resourceId = mdata.getString("resourceId");
        r.name = mdata.getString("name");
        r.value_ = getDouble(mj, "value");
        r.unit = mdata.getString("unit");
        r.category = mdata.getString("category");
        batchReq.metrics ~= r;
      }

      auto result = usecase.pushMetricBatch(batchReq);
      auto resp = Json.emptyObject
        .set("accepted", batchReq.metrics.length)
        .set("message", "Metrics batch pushed successfully");

      res.writeJsonBody(resp, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto resourceId = req.params.get("resourceId", "");
      auto metricName = req.params.get("name", "");

      QueryMetricsRequest qr;
      qr.tenantId = tenantId;
      qr.resourceId = resourceId;
      qr.metricName = metricName;

      auto metrics = usecase.queryMetrics(qr);
      auto arr = metrics.map!(m => m.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(metrics.length))
        .set("message", "Metrics retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto resourceId = MonitoredResourceId(req.params.get("resourceId", ""));
      auto metricName = req.params.get("name", "");

    
      auto now = Clock.currTime().toUnixTime();
      auto windowStart = now - 3600; // Default 1 hour window

      auto summary = usecase.computeSummary(tenantId, resourceId, metricName, windowStart, now);

      auto resp = Json.emptyObject
        .set("name", summary.name)
        .set("resourceId", summary.resourceId)
        .set("minValue", summary.minValue)
        .set("maxValue", summary.maxValue)
        .set("avgValue", summary.avgValue)
        .set("sumValue", summary.sumValue)
        .set("dataPointCount", summary.dataPointCount)
        .set("windowStartTime", summary.windowStartTime)
        .set("windowEndTime", summary.windowEndTime)
        .set("message", "Metric summary retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeMetric(const ref Metric m) {
    return Json.emptyObject
      .set("id", m.id)
      .set("tenantId", m.tenantId)
      .set("resourceId", m.resourceId)
      .set("definitionId", m.definitionId)
      .set("name", m.name)
      .set("value", m.value_)
      .set("unit", m.unit.to!string)
      .set("category", m.category.to!string)
      .set("timestamp", m.timestamp);
  }
}
