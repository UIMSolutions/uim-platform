/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.overview;

// import uim.platform.logging.application.usecases.get_overview;
// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class OverviewController : PlatformController {
  private GetOverviewUseCase uc;

  this(GetOverviewUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/overview", &handleOverview);
  }

  private void handleOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto response = Json.emptyObject
        .set("totalLogEntries", summary.totalLogEntries)
        .set("totalSpans", summary.totalSpans)
        .set("totalStreams", summary.totalStreams)
        .set("totalDashboards", summary.totalDashboards)
        .set("totalAlerts", summary.totalAlerts)
        .set("openAlerts", summary.openAlerts)
        .set("criticalAlerts", summary.criticalAlerts)
        .set("totalPipelines", summary.totalPipelines)
        .set("activePipelines", summary.activePipelines)
        .set("totalChannels", summary.totalChannels);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
