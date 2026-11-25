/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the tenant statistics (KPI header of the Fiori app,
/// CLI "stats", monitoring).
module uim.platform.job_scheduling.ports.services.statistics;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct JsStatistics {
  string tenantId;
  bool schedulerEnabled;
  long jobs;
  long activeJobs;
  long schedules;
  long activeSchedules;
  long runLogs;
  long scheduledRuns; /// waiting for execution
  long activeRuns; /// triggered or running (asynchronous, waiting for the callback)
  long completedRuns;
  long failedRuns; /// failed, retry pending
  long deadLetteredRuns;
  long runsLast24h;
  long failedLast24h; /// failed or dead lettered attempts that ended in the last 24 hours
  long successRateLast24h; /// percent of the runs that ended in the last 24 hours (100 if none)
  long nextRunAt; /// earliest planned run (std time, 0 = none)
  long lastRunAt; /// latest started run
  long computedAt;
}

interface IJsStatisticsService {
  JsStatistics compute(TenantId t);
}
