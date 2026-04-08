/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.dashboard;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;

import uim.platform.monitoring.application.usecases.get_dashboard;
import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.presentation.http.json_utils;

class DashboardController {
  private GetDashboardUseCase uc;

  this(GetDashboardUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    router.get("/api/v1/dashboard", &handleDashboard);
  }

  private void handleDashboard(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto j = Json.emptyObject;
      j["totalResources"] = Json(summary.totalResources);
      j["healthyResources"] = Json(summary.healthyResources);
      j["unhealthyResources"] = Json(summary.unhealthyResources);
      j["totalAlerts"] = Json(summary.totalAlerts);
      j["openAlerts"] = Json(summary.openAlerts);
      j["criticalAlerts"] = Json(summary.criticalAlerts);
      j["totalChecks"] = Json(summary.totalChecks);
      j["failingChecks"] = Json(summary.failingChecks);
      j["totalMetricDefinitions"] = Json(summary.totalMetricDefinitions);
      j["totalChannels"] = Json(summary.totalChannels);

      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
