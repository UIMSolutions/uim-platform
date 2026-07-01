/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.usage_statistics;

  // import uim.platform.ai_launchpad.domain.types;
  // import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IUsageStatisticRepository : ITenantRepository!(UsageStatistic, UsageStatisticId) {

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  UsageStatistic[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId);
  UsageStatistic[] findByConnection(TenantId tenantId, ConnectionId connectionId);
  void removeByConnection(TenantId tenantId, ConnectionId connectionId);

  size_t countByPeriod(TenantId tenantId, StatisticsPeriod period);
  UsageStatistic[] findByPeriod(TenantId tenantId, StatisticsPeriod period);
  void removeByPeriod(TenantId tenantId, StatisticsPeriod period);

}
