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

class StatisticsController : PlatformController {
  private GetUsageStatisticsUseCase usecase;

  this(GetUsageStatisticsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/statistics", &handleGet);
  }

  protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
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

      auto jarr = stats.map!(s => s.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", stats.length)
        .set("resources", jarr)
        .set("message", "Usage statistics retrieved");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
