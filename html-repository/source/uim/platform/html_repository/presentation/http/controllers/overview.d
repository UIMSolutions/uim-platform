/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.overview;

import uim.platform.html_repository.application.usecases.get_overview;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class OverviewController : SAPController {
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
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto summary = uc.getSummary(tenantId);
      if (summary is null) {
        writeError(res, 404, "Overview not available");
        return;
      }
      auto obj = Json.emptyObject;
      obj["totalApps"] = Json(cast(long) summary.totalApps);
      obj["totalVersions"] = Json(cast(long) summary.totalVersions);
      obj["totalFiles"] = Json(cast(long) summary.totalFiles);
      obj["totalInstances"] = Json(cast(long) summary.totalInstances);
      obj["totalDeployments"] = Json(cast(long) summary.totalDeployments);
      obj["totalRoutes"] = Json(cast(long) summary.totalRoutes);
      obj["totalCacheEntries"] = Json(cast(long) summary.totalCacheEntries);
      obj["cacheHitRate"] = Json(summary.cacheHitRate);
      obj["totalStorageBytes"] = Json(cast(long) summary.totalStorageBytes);
      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
