/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the scheduler engine (background worker, "run due" actions).
module uim.platform.job_scheduling.ports.usecases.scheduler;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IRunScheduler {
  /// One scheduler pass for a tenant: fire due schedules, execute
  /// scheduled runs and due retries, fail timed out runs, purge old logs.
  TickSummary tick(TenantId t, UserId actor);
  /// Execute one scheduled run (or a due retry) now.
  RunLog execute(TenantId t, RunLogId id, UserId actor);
}
