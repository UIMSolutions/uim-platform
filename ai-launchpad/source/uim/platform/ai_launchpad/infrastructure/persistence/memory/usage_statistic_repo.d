/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.usage_statistic_repo;

import uim.platform.ai_launchpad.domain.ports.repositories.usage_statistics;
import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;
import uim.platform.ai_launchpad.domain.types;

class MemoryUsageStatisticRepository : IUsageStatisticRepository {
  private UsageStatistic[] store;

  void save(UsageStatistic s) {
    store ~= s;
  }

  UsageStatistic[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    UsageStatistic[] result;
    foreach (ref s; store) {
      if (s.scenarioId == scenarioId && s.connectionId == connectionId) result ~= s;
    }
    return result;
  }

  UsageStatistic[] findByConnection(ConnectionId connectionId) {
    UsageStatistic[] result;
    foreach (ref s; store) {
      if (s.connectionId == connectionId) result ~= s;
    }
    return result;
  }

  UsageStatistic[] findByPeriod(StatisticsPeriod period) {
    UsageStatistic[] result;
    foreach (ref s; store) {
      if (s.period == period) result ~= s;
    }
    return result;
  }

  UsageStatistic[] findAll() {
    return store.dup;
  }
}
