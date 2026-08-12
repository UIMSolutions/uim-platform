/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.get_usage_statistics;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IGetUsageStatisticsUseCase { 

  UsageStatistic[] listStatistics(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId);

  UsageStatistic[] listStatistics(TenantId tenantId, ConnectionId connectionId);

  UsageStatistic[] listStatistics(TenantId tenantId, StatisticsPeriod period);

  UsageStatistic[] listStatistics(TenantId tenantId);
  
}
