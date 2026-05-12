/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.dashboard;



// import vibe.data.json;

// import uim.platform.monitoring.application.usecases.get_dashboard;
// import uim.platform.monitoring.application.dto;

import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class DashboardController : PlatformController {
  private GetDashboardUseCase usecase;

  this(GetDashboardUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/dashboard", &handleDashboard);
  }

  private void handleDashboard(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto summary = usecase.getSummary(tenantId);

      auto j = Json.emptyObject
        .set("totalResources", summary.totalResources)
        .set("healthyResources", summary.healthyResources)
        .set("unhealthyResources", summary.unhealthyResources)
        .set("totalAlerts", summary.totalAlerts)
        .set("openAlerts", summary.openAlerts)
        .set("criticalAlerts", summary.criticalAlerts)
        .set("totalChecks", summary.totalChecks)
        .set("failingChecks", summary.failingChecks)
        .set("totalMetricDefinitions", summary.totalMetricDefinitions)
        .set("totalChannels", summary.totalChannels);

      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
