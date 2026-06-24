/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.dashboard;

// import uim.platform.monitoring.application.usecases.get_dashboard;
// import uim.platform.monitoring.application.dto;

import uim.platform.monitoring;

// mixin(ShowModule!());

@safe:
class DashboardController : HttpController {
  private GetDashboardUseCase usecase;

  this(GetDashboardUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/dashboard", &handleDashboard);
  }

  protected Json dashboardHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
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
    return successResponse("Dashboard retrieved successfully", "Retrieved", 200, j);
  }

  mixin(HandleTemplate!("handleDashboard", "dashboardHandler"));

}
