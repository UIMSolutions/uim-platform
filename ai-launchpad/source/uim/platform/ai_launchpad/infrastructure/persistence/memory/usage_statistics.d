/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.usage_statistics;

// import uim.platform.ai_launchpad.domain.ports.repositories.usage_statistics;
// import uim.platform.ai_launchpad.domain.entities.usage_statistic : UsageStatistic;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryUsageStatisticRepository : TenantRepository!(UsageStatistic, UsageStatisticId), IUsageStatisticRepository {

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }
  UsageStatistic[] filterByScenario(UsageStatistic[] stats, ScenarioId scenarioId) {
    return stats.filter!(s => s.scenarioId == scenarioId).array;
  }
  UsageStatistic[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    findByScenario(tenantId, connectionId, scenarioId).each!(s => remove(s));
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  UsageStatistic[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(s => remove(s));
  }

  size_t countByPeriod(TenantId tenantId, StatisticsPeriod period) {
    return findByPeriod(tenantId, period).length;
  }
  UsageStatistic[] filterByPeriod(UsageStatistic[] stats, StatisticsPeriod period) {
    return stats.filter!(s => s.period == period).array;
  }
  UsageStatistic[] findByPeriod(TenantId tenantId, StatisticsPeriod period) {
    return filterByPeriod(findByTenant(tenantId), period);
  }
  void removeByPeriod(TenantId tenantId, StatisticsPeriod period) {
    findByPeriod(tenantId, period).each!(s => remove(s));
  }

}
