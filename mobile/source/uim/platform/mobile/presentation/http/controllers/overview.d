/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.overview;

import uim.platform.mobile.application.usecases.get_overview;
import uim.platform.mobile.application.dto;

import uim.platform.mobile;

import std.conv : to;

class OverviewController : PlatformController {
  private GetOverviewUseCase uc;

  this(GetOverviewUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/overview", &handleGetOverview);
  }

  private void handleGetOverview(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);
      auto resp = Json.emptyObject
        .set("totalApps", Json(summary.totalApps))
        .set("totalDevices", Json(summary.totalDevices))
        .set("totalSessions", Json(summary.totalSessions))
        .set("totalPushNotifications", Json(summary.totalPushNotifications))
        .set("totalFeatureFlags", Json(summary.totalFeatureFlags))
        .set("totalOfflineStores", Json(summary.totalOfflineStores))
        .set("totalUsageReports", Json(summary.totalUsageReports))
        .set("totalClientLogs", Json(summary.totalClientLogs))
        .set("message", "Overview retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
