/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.presentation.http.controllers.custom_metrics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class CustomMetricController : ManageController {
  private ManageCustomMetricsUseCase usecase;

  this(ManageCustomMetricsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    // POST /api/v1/apps/{appId}/metrics  — submit custom metric values
    router.post("/api/v1/apps/*/metrics", &handleSubmit);
    // GET  /api/v1/apps/{appId}/metrics  — query current metrics
    router.get("/api/v1/apps/*/metrics",  &handleQuery);
  }

  // POST /api/v1/apps/{appId}/metrics
  protected void handleSubmit(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = extractIdFromPath(req);
      auto j = req.json;

      // Support batch: {"metrics": [...]} or single object
      auto metricsJ = j["metrics"];
      if (metricsJ.type == Json.Type.array) {
        foreach (mj; metricsJ.byValue) {
          SubmitCustomMetricRequest r;
          r.appId      = appId;
          r.metricName = mj.getString("name");
          r.value      = mj.type == Json.Type.object ? mj["value"].get!double : 0.0;
          r.unit       = mj.getString("unit");
          r.timestamp  = mj.type == Json.Type.object && mj["timestamp"].type == Json.Type.int_
            ? mj["timestamp"].get!long : 0;
          usecase.submit(r);
        }
        res.writeJsonBody(Json.emptyObject.set("message", "Metrics submitted"), 200);
      } else {
        SubmitCustomMetricRequest r;
        r.appId      = appId;
        r.metricName = j.getString("name");
        r.value      = j["value"].type == Json.Type.float_ ? j["value"].get!double : 0.0;
        r.unit       = j.getString("unit");
        r.timestamp  = j["timestamp"].type == Json.Type.int_ ? j["timestamp"].get!long : 0;
        auto result = usecase.submit(r);
        if (result.success)
          res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Metric submitted"), 201);
        else
          writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/apps/{appId}/metrics
  protected void handleQuery(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto appId = extractIdFromPath(req);
      string metricName;
      foreach (kv; req.query.byKeyValue()) {
        if (kv.key == "name") { metricName = kv.value; break; }
      }
      auto metrics = usecase.getMetrics(appId, metricName);
      auto arr = Json.emptyArray;
      foreach (m; metrics) arr ~= m.toJson();
      res.writeJsonBody(Json.emptyObject.set("items", arr).set("totalCount", metrics.length), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
