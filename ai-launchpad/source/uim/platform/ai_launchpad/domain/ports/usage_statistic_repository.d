/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usage_statistic_repository;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;

interface IUsageStatisticRepository {
  void save(UsageStatistic s);
  UsageStatistic[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId);
  UsageStatistic[] findByConnection(ConnectionId connectionId);
  UsageStatistic[] findByPeriod(StatisticsPeriod period);
  UsageStatistic[] findAll();
}
