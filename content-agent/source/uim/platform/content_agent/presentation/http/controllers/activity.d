/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.activity;

// import uim.platform.content_agent.application.usecases.monitor_activities;
// import uim.platform.content_agent.domain.entities.content_activity;

import uim.platform.content_agent;

// mixin(ShowModule!());

@safe:
class ActivityController : ManageHttpController {
  private MonitorActivitiesUseCase usecase;

  this(MonitorActivitiesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/activities", &handleList);
    router.get("/api/v1/activities/summary", &handleSummary);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto activities = usecase.listActivities(tenantId);
    auto list = activities.map!(item => item.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Activity list retrieved successfully", "Retrieved", 200, responseData);
  }

  protected void handleGetSummary(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto precheck = super.getHandler(req);
      auto tenantId = precheck.tenantId;
      auto summary = usecase.getSummary(tenantId);

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
}
