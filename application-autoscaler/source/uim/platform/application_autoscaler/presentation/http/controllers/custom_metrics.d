/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.custom_metrics;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class CustomMetricController : ManageHttpController {
  private ManageCustomMetricsUseCase usecase;

  this(ManageCustomMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // POST /api/v1/apps/{appId}/metrics  — submit custom metric values
    router.post("/api/v1/apps/*/metrics", &handleSubmit);
    // GET  /api/v1/apps/{appId}/metrics  — query current metrics
    router.get("/api/v1/apps/*/metrics", &handleQuery);
  }

  // POST /api/v1/apps/{appId}/metrics
  protected Json submitHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto appId = precheck.id;
    auto data = precheck.data;
    // Support batch: {"metrics": [...]} or single object
    auto metricsJ = data["metrics"];
    if (metricsJ.isArray) {
      foreach (mj; metricsJ.byValue) {
        SubmitCustomMetricRequest r;
        r.appId = appId;
        r.metricName = data.getString("name");
        r.value = mj.isObject ? mj["value"].get!double : 0.0;
        r.unit = data.getString("unit");
        r.timestamp = mj.isObject && mj["timestamp"].isInteger
          ? mj["timestamp"].get!long : 0;
        usecase.submit(r);
      }

      return successResponse("Metrics submitted", "Submitted", 200, Json.emptyObject.set("count", metricsJ
          .length));
    }

    SubmitCustomMetricRequest r;
    r.appId = appId;
    r.metricName = data.getString("name");
    r.value = data["value"].isFloat ? data["value"].get!double : 0.0;
    r.unit = data.getString("unit");
    r.timestamp = data["timestamp"].isInteger ? data["timestamp"].get!long : 0;
    auto result = usecase.submit(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Metric submitted", "Submitted", 201, resp);
  }

  protected void handleSubmit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {

      auto response = submitHandler(req);
      res.writeJsonBody(response, response.code);

    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json queryHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto appId = precheck.id;
    string metricName;
    foreach (kv; req.query.byKeyValue()) {
      if (kv.key == "name") {
        metricName = kv.value;
        break;
      }
    }
    auto metrics = usecase.getMetrics(tenantId, appId, metricName);
    auto arr = Json.emptyArray;
    foreach (m; metrics)
      arr ~= m.toJson();

    return successResponse("Metrics retrieved", "Retrieved", 200, Json.emptyObject.set("items", arr).set("totalCount", metrics
        .length));
  }

  mixin(HandleTemplate!("handleQuery", "queryHandler"));

}
