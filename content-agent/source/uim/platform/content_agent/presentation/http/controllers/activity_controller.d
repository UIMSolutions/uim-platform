/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.activity_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.content_agent.application.usecases.monitor_activities;
// import uim.platform.content_agent.domain.entities.content_activity;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class ActivityController : PlatformController {
  private MonitorActivitiesUseCase uc;

  this(MonitorActivitiesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/activities", &handleList);
    router.get("/api/v1/activities/summary", &handleSummary);
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;

      auto activities = uc.listActivities(tenantId);
      auto arr = activities.map!(a => a.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(activities.length))
        .set("message", "Activities retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto summary = uc.getSummary(tenantId);

      auto j = Json.emptyObject
        .set("totalCount", Json(summary.totalCount))
        .set("infoCount", Json(summary.infoCount))
        .set("warningCount", Json(summary.warningCount))
        .set("errorCount", Json(summary.errorCount))
        .set("message", "Activity summary retrieved successfully");
        
      res.writeJsonBody(j, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeActivity(const ContentActivity a) {
    return Json.emptyObject
      .set("id", a.id)
      .set("tenantId", a.tenantId)
      .set("activityType", a.activityType.to!string)
      .set("severity", a.severity.to!string)
      .set("entityId", a.entityId)
      .set("entityName", a.entityName)
      .set("description", a.description)
      .set("performedBy", a.performedBy)
      .set("timestamp", a.timestamp)
      .set("details", a.details);
  }
}
