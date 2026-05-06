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
  private GetUsageStatisticsUseCase uc;

  this(GetUsageStatisticsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/api/v1/statistics", &handleGet);
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));
      auto period = req.headers.get("X-Period", "").to!StatisticsPeriod;

      typeof(uc.getAll()) stats;
      if (scenarioId.length > 0 && connectionId.length > 0)
        stats = uc.getByScenario(connectionId, scenarioId);
      else if (connectionId.length > 0)
        stats = uc.getByConnection(connectionId);
      else
        stats = uc.getAll();

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
