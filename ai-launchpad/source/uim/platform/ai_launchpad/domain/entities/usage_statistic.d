/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.usage_statistic;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;
mixin(ShowModule!());

@safe:

struct UsageStatistic {
  mixin TenantEntity!UsageStatisticId;
  
  ScenarioId scenarioId;
  ConnectionId connectionId;
  StatisticsPeriod period;
  int executionCount;
  int deploymentCount;
  double totalTrainingHours;
  long totalInferenceRequests;
  double estimatedCost;
  long computedAt;

  Json toJson() const {
    return entityToJson
      .set("scenario_id", scenarioId)
      .set("connection_id", connectionId)
      .set("period", period.to!string)
      .set("execution_count", executionCount)
      .set("deployment_count", deploymentCount)
      .set("total_training_hours", totalTrainingHours)
      .set("total_inference_requests", totalInferenceRequests)
      .set("estimated_cost", estimatedCost)
      .set("computed_at", computedAt);
  }
}
