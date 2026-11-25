/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the run logs (read, asynchronous result reports,
/// retries, housekeeping).
module uim.platform.job_scheduling.ports.usecases.run_logs;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

interface IManageRunLogs {
  RunLog get(TenantId t, RunLogId id);
  RunLog[] list(TenantId t);
  RunLog[] listByJob(TenantId t, JobId job);
  /// Not while the run is active.
  void remove(TenantId t, RunLogId id, UserId actor);
  /// Result of an asynchronous run (the callback of the job endpoint).
  RunLog report(ReportRunRequest r);
  /// Run a failed or dead lettered run again (one more attempt).
  RunLog retry(TenantId t, RunLogId id, UserId actor);
  /// Remove final run logs that ended more than olderThanDays ago; returns the number removed.
  long purge(TenantId t, int olderThanDays, UserId actor);
}
