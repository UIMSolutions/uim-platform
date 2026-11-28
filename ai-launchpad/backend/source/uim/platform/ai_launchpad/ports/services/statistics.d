/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPIs of the launchpad tiles and the
/// headers of the apps, CLI "stats").
module uim.platform.ai_launchpad.ports.services.statistics;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct AilpStatistics {
  TenantId tenantId;
  long workspaces;
  long connections;
  long activeConnections;
  long resourceGroups;
  long scenarios;
  long configurations;
  long executions;
  long runningExecutions;
  long failedExecutions;
  long deployments;
  long runningDeployments;
  long models;
  long datasets;
  long promptCollections;
  long prompts;
  long activePrompts;
  long promptRuns;
  long users;
  long lockedUsers;
  long roles;
  long tiles;
  long logEntriesLast24h;
  long warningsLast24h;
}

interface IAilpStatisticsService {
  AilpStatistics compute(TenantId t);
}
