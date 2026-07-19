/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.monitoring;

// import uim.platform.foundry.application.usecases.monitor_apps;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:

class MonitoringController : ManageHttpController {
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

  protected Json listAppHealthHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = useCase.listAppHealth(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Application health summaries retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleListAppHealth", "listAppHealthHandler"));

  protected Json appHealthHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto h = useCase.getAppHealth(tenantId, id);
    if (h.appId.isEmpty)
      return errorResponse("Application not found", 404);

    auto responseData = serializeHealth(h);
    return successResponse("Application health summary retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleAppHealth", "appHealthHandler"));

  protected Json spaceUsageHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(precheck.id);
    if (spaceId.isNull)
      return errorResponse("Invalid space ID", 400);

    auto u = useCase.getSpaceUsage(tenantId, spaceId);
    if (u.spaceId.isEmpty)
      return errorResponse("Space not found", 404);

    auto responseData = Json.emptyObject
      .set("spaceId", u.spaceId)
      .set("totalApps", u.totalApps)
      .set("runningApps", u.runningApps)
      .set("stoppedApps", u.stoppedApps)
      .set("crashedApps", u.crashedApps)
      .set("totalMemoryUsedMb", u.totalMemoryUsedMb)
      .set("totalDiskUsedMb", u.totalDiskUsedMb)
      .set("totalServiceInstances", u.totalServiceInstances)
      .set("totalRoutes", u.totalRoutes);

    return successResponse("Space usage retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleSpaceUsage", "spaceUsageHandler"));

  private static Json serializeHealth(const AppHealthSummary h) {
    return Json.emptyObject
      .set("appId",   h.appId)
      .set("appName", h.appName)
      .set("state", h.state.to!string)
      .set("requestedInstances", h.requestedInstances)
      .set("runningInstances", h.runningInstances)
      .set("crashedInstances", h.crashedInstances)
      .set("totalMemoryMb", h.totalMemoryMb)
      .set("totalDiskMb", h.totalDiskMb);
  }
}
