/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the statistics (KPI header of the Fiori app, CLI "stats").
module uim.platform.integration_automation.ports.services.statistics;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

struct IaStatistics {
  TenantId tenantId;
  long systems;
  long reachableSystems;
  long unreachableSystems;
  long destinations;
  long scenarios;
  long activeScenarios;
  long draftScenarios;
  long workflows;
  long openWorkflows; /// planned, in progress, suspended, failed
  long maxOpenWorkflows; /// the limit per tenant
  long runningWorkflows;
  long suspendedWorkflows;
  long failedWorkflows;
  long completedWorkflows;
  long tasks;
  long openTasks; /// pending or in progress, of open workflows
  long readyTasks; /// can start now
  long myOpenTasks; /// open tasks assigned to the caller
  long failedTasks;
  long automatedTasks;
  long executionLogs;
  long failuresLast24h;
  long completionRate; /// % of finished workflows that completed
}

interface IIaStatisticsService {
  /// user: the caller (for myOpenTasks).
  IaStatistics compute(TenantId t, string user);
}
