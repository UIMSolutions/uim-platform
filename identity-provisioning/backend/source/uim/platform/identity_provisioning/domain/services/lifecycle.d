/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// State rules of systems and jobs.
module uim.platform.identity_provisioning.domain.services.lifecycle;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A job can only use active systems.
void ensureSystemActive(string kind, string name, SystemStatus status) {
  ensureState(status == SystemStatus.active,
    kind ~ " system '" ~ name ~ "' is " ~ enumText(status) ~ " — test and activate it first");
}

/// Running and cancelled jobs cannot be run.
void ensureRunnable(const ProvisioningJob job) {
  ensureState(job.status != JobStatus.running, "Job '" ~ job.name ~ "' is already running");
  ensureState(job.status != JobStatus.cancelled, "Job '" ~ job.name ~ "' is cancelled — resume it first");
}

/// Cancelled jobs cannot be cancelled again.
void ensureCancellable(const ProvisioningJob job) {
  ensureState(job.status != JobStatus.cancelled, "Job '" ~ job.name ~ "' is already cancelled");
}

/// Only cancelled jobs can be resumed.
void ensureResumable(const ProvisioningJob job) {
  ensureState(job.status == JobStatus.cancelled,
    "Job '" ~ job.name ~ "' is " ~ enumText(job.status) ~ ", only cancelled jobs can be resumed");
}

/// Running jobs cannot be changed, reset or deleted.
void ensureIdle(const ProvisioningJob job) {
  ensureState(job.status != JobStatus.running, "Job '" ~ job.name ~ "' is running");
}

/// Status after a run.
JobStatus statusAfterRun(int failedCount, bool connectorFailed) {
  return connectorFailed || failedCount > 0 ? JobStatus.failed : JobStatus.completed;
}

/// Next scheduled run (0 = on demand).
long nextRunAfter(long now, int intervalMinutes) {
  return intervalMinutes > 0 ? now + intervalMinutes * 600_000_000L : 0;
}

/// True if a scheduled job is due at `now`.
bool isDue(const ProvisioningJob job, long now) {
  return job.intervalMinutes > 0 && job.status != JobStatus.cancelled && job.status != JobStatus.running
    && job.nextRunAt > 0 && job.nextRunAt <= now;
}

///
unittest {
  ProvisioningJob job;
  job.name = "j";
  ensureRunnable(job);
  job.status = JobStatus.cancelled;
  bool conflict;
  try ensureRunnable(job);
  catch (ProvisioningConflictException) conflict = true;
  assert(conflict);
  ensureResumable(job);
  assert(statusAfterRun(0, false) == JobStatus.completed);
  assert(statusAfterRun(1, false) == JobStatus.failed && statusAfterRun(0, true) == JobStatus.failed);
  assert(nextRunAfter(100, 0) == 0 && nextRunAfter(100, 1) == 100 + 600_000_000L);
  job.status = JobStatus.completed;
  job.intervalMinutes = 5;
  job.nextRunAt = 10;
  assert(isDue(job, 10) && !isDue(job, 9));
}
