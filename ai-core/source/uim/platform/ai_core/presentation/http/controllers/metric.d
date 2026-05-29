/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.metric;
// import uim.platform.ai_core.application.usecases.get_metrics;
// import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class MetricController : PlatformController {
  private GetMetricsUseCase usecase;

  this(GetMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.patch("/api/v2/lm/metrics", &handlePatch);
    router.get("/api/v2/lm/metrics", &handleGet);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    PatchMetricsRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.executionId = ExecutionId(data.getString("executionId"));
    r.metrics = jsonKeyValuePairs(j, "metrics");
    r.tags = jsonKeyValuePairs(j, "tags");
    r.customInfo = jsonKeyValuePairs(j, "customInfo");

    auto result = usecase.patchMetric(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Metrics patched successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    auto execId = ExecutionId(req.params.get("executionId", ""));
    if (execId.isNull)
      return errorResponse("Execution ID is required", 400);

    auto metrics = usecase.listMetrics(tenantId, rgId, execId);
    auto list = Json.emptyArray;
    foreach (m; metrics) {
      auto vArr = Json.emptyArray;
      foreach (v; m.metrics) {
        vArr ~= Json.emptyObject
          .set("name", v.name)
          .set("value", v.value);
      }

      auto tArr = Json.emptyArray;
      foreach (t; m.tags) {
        tArr ~= Json.emptyObject
          .set("key", t.key)
          .set("value", t.value);
      }

      list ~= Json.emptyObject
        .set("id", m.id)
        .set("executionId", m.executionId)
        .set("createdAt", m.createdAt)
        .set("metrics", vArr)
        .set("tags", tArr);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Metrics retrieved successfully", "Retrieved", 200, responseData);
  }
}
