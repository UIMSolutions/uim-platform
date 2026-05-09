/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.get_usage_statistics;

// import uim.platform.ai_launchpad.domain.ports.repositories.usage_statistics;
// import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class GetUsageStatisticsUseCase { // TODO: UIMUseCase {
  private IUsageStatisticRepository repo;

  this(IUsageStatisticRepository repo) {
    this.repo = repo;
  }

  UsageStatistic[] listStatistics(TenantId tenantId, ScenarioId scenarioId, ConnectionId connectionId) {
    return repo.findByScenario(tenantId, scenarioId, connectionId);
  }

  UsageStatistic[] listStatistics(TenantId tenantId, ConnectionId connectionId) {
    return repo.findByConnection(tenantId, connectionId);
  }

  UsageStatistic[] listStatistics(TenantId tenantId, StatisticsPeriod period) {
    return repo.findByPeriod(tenantId, period);
  }

  UsageStatistic[] listStatistics(TenantId tenantId) {
    return repo.findAll(tenantId);
  }
}
