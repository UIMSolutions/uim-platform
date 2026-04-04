/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.get_usage_statistics;

import uim.platform.ai_launchpad.domain.ports.repositories.usage_statistics;
import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

class GetUsageStatisticsUseCase : UIMUseCase {
  private IUsageStatisticRepository repo;

  this(IUsageStatisticRepository repo) {
    this.repo = repo;
  }

  UsageStatistic[] getByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(scenarioId, connectionId);
  }

  UsageStatistic[] getByConnection(ConnectionId connectionId) {
    return repo.findByConnection(connectionId);
  }

  UsageStatistic[] getByPeriod(StatisticsPeriod period) {
    return repo.findByPeriod(period);
  }

  UsageStatistic[] getAll() {
    return repo.findAll();
  }
}
