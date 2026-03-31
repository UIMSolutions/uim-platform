module presentation.http.monitoring_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.monitor_apps;
import domain.types;
import presentation.http.json_utils;

class MonitoringController
{
  private MonitorAppsUseCase useCase;

  this(MonitorAppsUseCase useCase)
  {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router)
  {
    router.get("/api/v1/monitoring/apps", &handleListAppHealth);
    router.get("/api/v1/monitoring/spaces/*", &handleSpaceUsage);
    router.get("/api/v1/monitoring/apps/*", &handleAppHealth);
  }

  private void handleListAppHealth(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = useCase.listAppHealth(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref h; items)
        arr ~= serializeHealth(h);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAppHealth(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto h = useCase.getAppHealth(id, tenantId);
      if (h.appId.length == 0)
      {
        writeError(res, 404, "Application not found");
        return;
      }
      res.writeJsonBody(serializeHealth(h), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSpaceUsage(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto spaceId = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto u = useCase.getSpaceUsage(spaceId, tenantId);

      auto j = Json.emptyObject;
      j["spaceId"] = Json(u.spaceId);
      j["totalApps"] = Json(u.totalApps);
      j["runningApps"] = Json(u.runningApps);
      j["stoppedApps"] = Json(u.stoppedApps);
      j["crashedApps"] = Json(u.crashedApps);
      j["totalMemoryUsedMb"] = Json(u.totalMemoryUsedMb);
      j["totalDiskUsedMb"] = Json(u.totalDiskUsedMb);
      j["totalServiceInstances"] = Json(u.totalServiceInstances);
      j["totalRoutes"] = Json(u.totalRoutes);
      res.writeJsonBody(j, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeHealth(ref const AppHealthSummary h)
  {
    auto j = Json.emptyObject;
    j["appId"] = Json(h.appId);
    j["appName"] = Json(h.appName);
    j["state"] = Json(h.state.to!string);
    j["requestedInstances"] = Json(h.requestedInstances);
    j["runningInstances"] = Json(h.runningInstances);
    j["crashedInstances"] = Json(h.crashedInstances);
    j["totalMemoryMb"] = Json(h.totalMemoryMb);
    j["totalDiskMb"] = Json(h.totalDiskMb);
    return j;
  }
}
