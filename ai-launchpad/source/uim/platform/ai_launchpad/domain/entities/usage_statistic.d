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
  StatisticsId id;
  ScenarioId scenarioId;
  ConnectionId connectionId;
  StatisticsPeriod period;
  int executionCount;
  int deploymentCount;
  double totalTrainingHours;
  long totalInferenceRequests;
  double estimatedCost;
  string computedAt;
}
