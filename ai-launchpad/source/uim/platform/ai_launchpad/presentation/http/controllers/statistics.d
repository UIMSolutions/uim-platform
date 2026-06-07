/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.statistics;

// import uim.platform.ai_launchpad.application.usecases.get_usage_statistics;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class StatisticsController : HttpController {
  private GetUsageStatisticsUseCase usecase;

  this(GetUsageStatisticsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/statistics", &handleGet);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ScenarioId(precheck.id);
    if (id.isNull)
         return errorResponse("Invalid scenario ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));
    auto period = req.headers.get("X-Period", "").to!StatisticsPeriod;

    UsageStatistic[] stats;
    if (!scenarioId.isEmpty && !connectionId.isEmpty)
      stats = usecase.listStatistics(tenantId, connectionId, scenarioId);
    else if (!connectionId.isEmpty)
      stats = usecase.listStatistics(tenantId, connectionId);
    else
      stats = usecase.listStatistics(tenantId);

    auto list = stats.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Statistics retrieved successfully", "Retrieved", 200, responseData);
  }
}
