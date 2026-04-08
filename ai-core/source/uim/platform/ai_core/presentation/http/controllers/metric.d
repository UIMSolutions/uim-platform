/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.metric;

import uim.platform.ai_core.application.usecases.get_metrics;
import uim.platform.ai_core.application.dto;

import uim.platform.ai_core;

class MetricController : SAPController {
  private GetMetricsUseCase uc;

  this(GetMetricsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.patch_("/api/v2/lm/metrics", &handlePatch);
    router.get("/api/v2/lm/metrics", &handleGet);
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      PatchMetricsRequest r;
      r.tenantId = req.getTenantId;
      r.resourceGroupId = req.headers.get("AI-Resource-Group", "");
      r.executionId = j.getString("executionId");
      r.metrics = jsonKeyValuePairs(j, "metrics");
      r.tags = jsonKeyValuePairs(j, "tags");
      r.customInfo = jsonKeyValuePairs(j, "customInfo");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        resp["message"] = Json("Metrics stored");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto rgId = req.headers.get("AI-Resource-Group", "");
      auto execId = req.params.get("executionId", "");

      if (execid.isEmpty) {
        writeError(res, 400, "executionId query parameter is required");
        return;
      }

      auto metrics = uc.listByExecution(execId, rgId);

      auto jarr = Json.emptyArray;
      foreach (ref m; metrics) {
        auto mj = Json.emptyObject;
        mj["id"] = Json(m.id);
        mj["executionId"] = Json(m.executionId);
        mj["createdAt"] = Json(m.createdAt);

        auto vArr = Json.emptyArray;
        foreach (ref v; m.metrics) {
          auto vj = Json.emptyObject;
          vj["name"] = Json(v.name);
          vj["value"] = Json(v.value);
          vArr ~= vj;
        }
        mj["metrics"] = vArr;

        auto tArr = Json.emptyArray;
        foreach (ref t; m.tags) {
          auto tj = Json.emptyObject;
          tj["key"] = Json(t.key);
          tj["value"] = Json(t.value);
          tArr ~= tj;
        }
        mj["tags"] = tArr;

        jarr ~= mj;
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) metrics.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
