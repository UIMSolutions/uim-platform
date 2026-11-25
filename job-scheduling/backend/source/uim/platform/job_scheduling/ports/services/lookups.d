/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of cheap per-job facts for list views ("3 schedules, next
/// run at …, last run failed") — one pass over schedules and run logs.
module uim.platform.job_scheduling.ports.services.lookups;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct JobFacts {
  long schedules;
  long activeSchedules;
  long nextRunAt;
  long lastRunAt;
  string lastRunStatus;
  long runs;
  long failedRuns; /// failed or dead lettered
}

interface IJsLookups {
  /// Facts per job id.
  JobFacts[string] jobFacts(TenantId t);
}
