/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.statistics;

import uim.platform.ai_launchpad.application.usecases.get_usage_statistics;
import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad.presentation.http.json_utils;

import uim.platform.ai_launchpad;

class StatisticsController : SAPController {
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
      auto connectionId = req.headers.get("X-Connection-Id", "");
      auto scenarioId = req.headers.get("X-Scenario-Id", "");
      auto period = req.headers.get("X-Period", "");

      typeof(uc.getAll()) stats;
      if (scenarioId.length > 0 && connectionId.length > 0)
        stats = uc.getByScenario(scenarioId, connectionId);
      else if (connectionId.length > 0)
        stats = uc.getByConnection(connectionId);
      else
        stats = uc.getAll();

      auto jarr = Json.emptyArray;
      foreach (ref s; stats) {
        jarr ~= serializeStatistic(s);
      }

      auto resp = Json.emptyObject;
      resp["count"] = Json(cast(long) stats.length);
      resp["resources"] = jarr;
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private Json serializeStatistic(UsageStatistic s) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["scenarioId"] = Json(s.scenarioId);
    j["connectionId"] = Json(s.connectionId);
    j["period"] = Json(s.period.to!string);
    j["executionCount"] = Json(cast(long) s.executionCount);
    j["deploymentCount"] = Json(cast(long) s.deploymentCount);
    j["totalTrainingHours"] = Json(s.totalTrainingHours);
    j["totalInferenceRequests"] = Json(s.totalInferenceRequests);
    j["estimatedCost"] = Json(s.estimatedCost);
    j["computedAt"] = Json(s.computedAt);
    return j;
  }
}
