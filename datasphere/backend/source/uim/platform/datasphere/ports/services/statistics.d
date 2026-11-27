/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.datasphere.ports.services.statistics;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct DspStatistics {
  TenantId tenantId;
  long spaces;
  long lockedSpaces;
  long members;
  long connections;
  long validConnections;
  long remoteTables;
  long replicatedTables;
  long views;
  long deployedViews;
  long exposedViews;
  long dataFlows;
  long tasks;
  long scheduledTasks;
  long taskChains;
  long runsLast24h;
  long failedRunsLast24h;
  long accessControls;
  long catalogAssets;
  long usedDiskMiB;
  long diskQuotaMiB;
  long users;
}

interface IDspStatisticsService {
  DspStatistics compute(TenantId t);
}
