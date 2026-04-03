/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.overview;

import uim.platform.mobile.application.use_cases.get_overview;
import uim.platform.mobile.application.dto;
import uim.platform.mobile.presentation.http.json_utils;

import uim.platform.mobile;

import std.conv : to;

class OverviewController : SAPController {
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = uc.getSummary(tenantId);
      auto resp = Json.emptyObject;
      resp["totalApps"] = Json(summary.totalApps);
      resp["totalDevices"] = Json(summary.totalDevices);
      resp["totalSessions"] = Json(summary.totalSessions);
      resp["totalPushNotifications"] = Json(summary.totalPushNotifications);
      resp["totalFeatureFlags"] = Json(summary.totalFeatureFlags);
      resp["totalOfflineStores"] = Json(summary.totalOfflineStores);
      resp["totalUsageReports"] = Json(summary.totalUsageReports);
      resp["totalClientLogs"] = Json(summary.totalClientLogs);
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
