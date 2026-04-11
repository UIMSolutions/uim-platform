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

      auto arr = Json.emptyArray;
      foreach (l; logs)
        arr ~= serializeLog(l);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) logs.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto j = Json.emptyObject;
      j["totalEvents"] = Json(cast(long) summary.totalEvents);
      j["info"] = Json(cast(long) summary.infoCount);
      j["warning"] = Json(cast(long) summary.warningCount);
      j["error"] = Json(cast(long) summary.errorCount);
      j["critical"] = Json(cast(long) summary.criticalCount);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeLog(const ConnectivityLog l) {
    auto j = Json.emptyObject;
    j["id"] = Json(l.id);
    j["tenantId"] = Json(l.tenantId);
    j["eventType"] = Json(l.eventType.to!string);
    j["severity"] = Json(l.severity.to!string);
    j["sourceId"] = Json(l.sourceId);
    j["sourceType"] = Json(l.sourceType);
    j["message"] = Json(l.message);
    j["remoteHost"] = Json(l.remoteHost);
    j["remotePort"] = Json(cast(long) l.remotePort);
    j["timestamp"] = Json(l.timestamp);
    return j;
  }
}
