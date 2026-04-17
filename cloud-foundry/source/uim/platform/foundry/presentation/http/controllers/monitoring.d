/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.monitoring;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.foundry.application.usecases.monitor_apps;
// import uim.platform.foundry.domain.types;
import uim.platform.connectivity;

class MonitoringController : PlatformController {
  private MonitorAppsUseCase useCase;

  this(MonitorAppsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/monitoring/apps", &handleListAppHealth);
    router.get("/api/v1/monitoring/spaces/*", &handleSpaceUsage);
    router.get("/api/v1/monitoring/apps/*", &handleAppHealth);
  }

  private void handleListAppHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
        TenantId tenantId = req.getTenantId;
      auto items = useCase.listAppHealth(tenantId);

      auto arr = Json.emptyArray;
      foreach (h; items)
        arr ~= serializeHealth(h);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAppHealth(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto h = useCase.getAppHealth(tenantId, id);
      if (h.appId.isEmpty) {
        writeError(res, 404, "Application not found");
        return;
      }
      res.writeJsonBody(serializeHealth(h), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSpaceUsage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto spaceId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto u = useCase.getSpaceUsage(tenantId, spaceId);

      auto j = Json.emptyObject
        .set("spaceId", u.spaceId)
        .set("totalApps", u.totalApps)
        .set("runningApps", u.runningApps)
        .set("stoppedApps", u.stoppedApps)
        .set("crashedApps", u.crashedApps)
        .set("totalMemoryUsedMb", u.totalMemoryUsedMb)
        .set("totalDiskUsedMb", u.totalDiskUsedMb)
        .set("totalServiceInstances", u.totalServiceInstances)
        .set("totalRoutes", u.totalRoutes);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeHealth(const AppHealthSummary h) {
    return Json.emptyObject
    .set("appId", Json(h.appId))
    .set("appName", Json(h.appName))
    .set("state", Json(h.state.to!string))
    .set("requestedInstances", Json(h.requestedInstances))
    .set("runningInstances", Json(h.runningInstances))
    .set("crashedInstances", Json(h.crashedInstances))
    .set("totalMemoryMb", Json(h.totalMemoryMb))
    .set("totalDiskMb", Json(h.totalDiskMb));
  }
}
