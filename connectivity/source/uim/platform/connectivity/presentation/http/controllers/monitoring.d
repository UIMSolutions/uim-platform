/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.monitoring;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.connectivity.application.usecases.monitor_connectivity;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.types;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/** 
 * Controller for connectivity monitoring endpoints, such as retrieving logs and summaries.
 *
 * TODO:
 * - Implement filtering, pagination, and other query parameters for log retrieval.  
 * - ConnectivityLog[] listBySeverity(TenantId tenantId, LogSeverity severity) 
 * - ConnectivityLog[] listBySource(TenantId tenantId, SourceId sourceId) 
 */
class MonitoringController : PlatformController {
  private MonitorConnectivityUseCase uc;

  this(MonitorConnectivityUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/monitoring/logs", &handleListLogs);
    router.get("/api/v1/monitoring/summary", &handleSummary);
  }

  private void handleListLogs(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;

      auto logs = uc.listLogs(tenantId);
      auto arr = logs.map!(l => l.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(logs.length))
        .set("message", "Logs retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto response = Json.emptyObject
        .set("totalEvents", summary.totalEvents)
        .set("info", summary.infoCount)
        .set("warning", summary.warningCount)
        .set("error", summary.errorCount)
        .set("critical", summary.criticalCount)
        .set("message", "Connectivity summary retrieved successfully");

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
