/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.job_scheduling.domain.enumerations.scheduling;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// HTTP method the scheduler uses to call the action endpoint of a job.
enum JobHttpMethod : string {
  get = "GET",
  post = "POST",
  put = "PUT",
  patch = "PATCH",
  delete_ = "DELETE"
}

/// How the expression of a schedule is written.
enum ScheduleFormat : string {
  cron = "cron", /// "*/5 * * * *" (UTC)
  repeatInterval = "repeatInterval", /// "10 minutes" — every interval after the previous run
  repeatAt = "repeatAt", /// "14:30" — every day at that time (UTC)
  time = "time", /// "2026-12-01T10:00:00Z" or "now" — one time
  humanReadable = "humanReadable" /// "every 10 minutes", "every day at 14:30", "in 5 minutes" — converted on save
}

/// One-time schedules deactivate themselves after their run.
enum ScheduleType : string {
  oneTime = "oneTime",
  recurring = "recurring"
}

/// Lifecycle of a run:
///   scheduled → triggered → completed                (synchronous, 2xx)
///   scheduled → triggered → running → completed      (asynchronous, 202 + callback)
///   … → failed → triggered (retry) … → deadLettered  (retries exhausted)
enum RunStatus : string {
  scheduled = "scheduled",
  triggered = "triggered",
  running = "running",
  completed = "completed",
  failed = "failed",
  deadLettered = "deadLettered"
}

/// What started a run.
enum RunTrigger : string {
  schedule = "schedule",
  manual = "manual"
}

///
unittest {
  assert(cast(string) JobHttpMethod.delete_ == "DELETE" && cast(string) RunStatus.deadLettered == "deadLettered");
}
