/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.overview;

import uim.platform.logging.application.usecases.get_overview;
import uim.platform.logging.application.dto;
import uim.platform.logging.presentation.http.json_utils;

import uim.platform.logging;

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

      auto j = Json.emptyObject;
      j["totalLogEntries"] = Json(summary.totalLogEntries);
      j["totalSpans"] = Json(summary.totalSpans);
      j["totalStreams"] = Json(summary.totalStreams);
      j["totalDashboards"] = Json(summary.totalDashboards);
      j["totalAlerts"] = Json(summary.totalAlerts);
      j["openAlerts"] = Json(summary.openAlerts);
      j["criticalAlerts"] = Json(summary.criticalAlerts);
      j["totalPipelines"] = Json(summary.totalPipelines);
      j["activePipelines"] = Json(summary.activePipelines);
      j["totalChannels"] = Json(summary.totalChannels);

      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
